#!/bin/bash

# SageMaker Unified Studio MVP Deployment Script
# This script handles AWSCC provider issues and validates successful deployment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if AWS CLI is available and configured
check_aws_cli() {
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed or not in PATH"
        exit 1
    fi
    
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS CLI is not configured or credentials are invalid"
        exit 1
    fi
    
    print_success "AWS CLI is configured and accessible"
}

# Function to get the AWS region from terraform
get_aws_region() {
    terraform output -raw region 2>/dev/null || echo "us-west-2"
}

# Function to wait for domain to be available
wait_for_domain() {
    local domain_id="$1"
    local aws_region="$2"
    local max_attempts=30
    local attempt=1
    
    print_status "Waiting for domain to be available: $domain_id (region: $aws_region)"
    
    while [ $attempt -le $max_attempts ]; do
        DOMAIN_STATUS=$(aws datazone get-domain \
            --region "$aws_region" \
            --identifier "$domain_id" \
            --query 'status' \
            --output text 2>/dev/null || echo "NOT_FOUND")
        
        case "$DOMAIN_STATUS" in
            "AVAILABLE")
                print_success "Domain is available"
                return 0
                ;;
            "CREATING")
                print_status "Domain is still creating... (attempt $attempt/$max_attempts)"
                ;;
            "NOT_FOUND")
                print_error "Domain not found: $domain_id"
                return 1
                ;;
            *)
                print_warning "Domain status: $DOMAIN_STATUS (attempt $attempt/$max_attempts)"
                ;;
        esac
        
        sleep 10
        attempt=$((attempt + 1))
    done
    
    print_error "Domain did not become available within expected time. Final status: $DOMAIN_STATUS"
    return 1
}

# Function to wait for project to be created and deployed
wait_for_project_creation() {
    local domain_id="$1"
    local aws_region="$2"
    local max_attempts=120  # 20 minutes (120 * 10 seconds)
    local attempt=1
    
    print_status "Waiting for project creation to complete (region: $aws_region)"
    print_status "Note: Project creation can take 5-15 minutes, especially with environment deployments..."
    
    while [ $attempt -le $max_attempts ]; do
        # Get the most recent project (likely the one we just created)
        RECENT_PROJECT=$(aws datazone list-projects \
            --region "$aws_region" \
            --domain-identifier "$domain_id" \
            --query 'items | sort_by(@, &createdAt) | [-1]' \
            --output json 2>/dev/null || echo "{}")
        
        if [ "$RECENT_PROJECT" = "{}" ] || [ "$RECENT_PROJECT" = "null" ]; then
            print_status "No projects found yet... (attempt $attempt/$max_attempts)"
            sleep 10
            attempt=$((attempt + 1))
            continue
        fi
        
        PROJECT_STATUS=$(echo "$RECENT_PROJECT" | jq -r '.projectStatus // "UNKNOWN"' 2>/dev/null || echo "UNKNOWN")
        PROJECT_ID=$(echo "$RECENT_PROJECT" | jq -r '.id // ""' 2>/dev/null || echo "")
        PROJECT_NAME=$(echo "$RECENT_PROJECT" | jq -r '.name // ""' 2>/dev/null || echo "")
        
        print_status "Found project: $PROJECT_NAME (ID: $PROJECT_ID, Status: $PROJECT_STATUS)"
        
        case "$PROJECT_STATUS" in
            "ACTIVE")
                # Project is active, now check environment deployment status
                print_status "Project is ACTIVE, checking environment deployment status..."
                
                # Get detailed project information
                DETAILED_PROJECT=$(aws datazone get-project \
                    --region "$aws_region" \
                    --domain-identifier "$domain_id" \
                    --identifier "$PROJECT_ID" \
                    --output json 2>/dev/null || echo "{}")
                
                if [ "$DETAILED_PROJECT" = "{}" ]; then
                    print_warning "Could not get detailed project information, retrying..."
                    sleep 10
                    attempt=$((attempt + 1))
                    continue
                fi
                
                # Check environment deployment status
                ENV_DEPLOYMENT_STATUS=$(echo "$DETAILED_PROJECT" | jq -r '.environmentDeploymentDetails.overallDeploymentStatus // "NONE"' 2>/dev/null || echo "NONE")
                
                case "$ENV_DEPLOYMENT_STATUS" in
                    "SUCCESSFUL_DEPLOYMENT"|"SUCCESSFUL")
                        print_success "✅ Project creation completed successfully with environment deployment"
                        return 0
                        ;;
                    "FAILED_DEPLOYMENT")
                        print_error "❌ Project created but environment deployment failed"
                        
                        # Show failure details
                        FAILURE_REASONS=$(echo "$DETAILED_PROJECT" | jq -r '.environmentDeploymentDetails.environmentFailureReasons // {}' 2>/dev/null || echo "{}")
                        if [ "$FAILURE_REASONS" != "{}" ] && [ "$FAILURE_REASONS" != "null" ]; then
                            print_error "Environment deployment failure reasons:"
                            echo "$FAILURE_REASONS" | jq -r 'to_entries[] | "  - \(.key): \(.value[0].message // "Unknown error")"' 2>/dev/null || echo "  - Unable to parse failure reasons"
                        fi
                        return 1
                        ;;
                    "IN_PROGRESS_DEPLOYMENT")
                        print_status "⏳ Project is active, environment deployment in progress... (attempt $attempt/$max_attempts)"
                        ;;
                    "NONE"|"null")
                        # No environment deployment details - this is normal for some project types
                        print_success "✅ Project creation completed successfully (no environment deployment configured)"
                        return 0
                        ;;
                    *)
                        print_status "⏳ Project is active, environment deployment status: $ENV_DEPLOYMENT_STATUS (attempt $attempt/$max_attempts)"
                        ;;
                esac
                ;;
            "CREATING")
                print_status "⏳ Project is still being created... (attempt $attempt/$max_attempts)"
                ;;
            "FAILED")
                print_error "❌ Project creation failed"
                return 1
                ;;
            "DELETING")
                print_error "❌ Project is being deleted"
                return 1
                ;;
            *)
                print_status "⏳ Project status: $PROJECT_STATUS (attempt $attempt/$max_attempts)"
                ;;
        esac
        
        sleep 10
        attempt=$((attempt + 1))
    done
    
    print_error "❌ Project creation did not complete within expected time (20 minutes)"
    print_error "Final status: $PROJECT_STATUS"
    return 1
}

# Function to validate current project deployment status
validate_project_deployment() {
    local domain_id="$1"
    local project_id="$2"
    local aws_region="$3"
    
    print_status "Validating project deployment status..."
    
    # Get detailed project information
    DETAILED_PROJECT=$(aws datazone get-project \
        --region "$aws_region" \
        --domain-identifier "$domain_id" \
        --identifier "$project_id" \
        --output json 2>/dev/null || echo "{}")
    
    if [ "$DETAILED_PROJECT" = "{}" ]; then
        print_error "Failed to get project details"
        return 1
    fi
    
    PROJECT_STATUS=$(echo "$DETAILED_PROJECT" | jq -r '.projectStatus // "UNKNOWN"' 2>/dev/null || echo "UNKNOWN")
    PROJECT_NAME=$(echo "$DETAILED_PROJECT" | jq -r '.name // "Unknown"' 2>/dev/null || echo "Unknown")
    
    print_status "Project: $PROJECT_NAME (ID: $project_id)"
    print_status "Project Status: $PROJECT_STATUS"
    
    # Check environment deployment details
    ENV_DEPLOYMENT_STATUS=$(echo "$DETAILED_PROJECT" | jq -r '.environmentDeploymentDetails.overallDeploymentStatus // "NONE"' 2>/dev/null || echo "NONE")
    
    if [ "$ENV_DEPLOYMENT_STATUS" != "NONE" ] && [ "$ENV_DEPLOYMENT_STATUS" != "null" ]; then
        print_status "Environment Deployment Status: $ENV_DEPLOYMENT_STATUS"
        
        case "$ENV_DEPLOYMENT_STATUS" in
            "SUCCESSFUL_DEPLOYMENT"|"SUCCESSFUL")
                print_success "✅ Project deployment is successful"
                return 0
                ;;
            "FAILED_DEPLOYMENT")
                print_error "❌ Project environment deployment failed"
                
                # Show raw failure details from AWS
                echo "$DETAILED_PROJECT" | jq '.environmentDeploymentDetails.environmentFailureReasons' 2>/dev/null || echo "Could not parse failure details"
                return 1
                ;;
            "IN_PROGRESS_DEPLOYMENT")
                print_warning "⏳ Environment deployment is still in progress"
                return 1
                ;;
            *)
                print_warning "⚠️  Unknown environment deployment status: $ENV_DEPLOYMENT_STATUS"
                return 1
                ;;
        esac
    else
        if [ "$PROJECT_STATUS" = "ACTIVE" ]; then
            print_success "✅ Project is active (no environment deployment details available)"
            return 0
        else
            print_error "❌ Project is not active: $PROJECT_STATUS"
            return 1
        fi
    fi
}

# Function to validate deployment
validate_deployment() {
    print_status "Validating deployment..."
    
    # Get AWS region from terraform
    AWS_REGION=$(get_aws_region)
    print_status "Using AWS region: $AWS_REGION"
    
    # Get domain ID from terraform output
    DOMAIN_ID=$(terraform output -raw domain_id 2>/dev/null || echo "")
    if [ -z "$DOMAIN_ID" ]; then
        print_error "Could not get domain ID from terraform output"
        return 1
    fi
    
    # Wait for domain to be available
    if ! wait_for_domain "$DOMAIN_ID" "$AWS_REGION"; then
        return 1
    fi
    
    # Wait for project creation to complete (this is the key addition)
    if ! wait_for_project_creation "$DOMAIN_ID" "$AWS_REGION"; then
        print_error "Project creation did not complete successfully"
        return 1
    fi
    
    # Now get the project details for final validation
    RECENT_PROJECT=$(aws datazone list-projects \
        --region "$AWS_REGION" \
        --domain-identifier "$DOMAIN_ID" \
        --query 'items | sort_by(@, &createdAt) | [-1]' \
        --output json 2>/dev/null || echo "{}")
    
    if [ "$RECENT_PROJECT" = "{}" ] || [ "$RECENT_PROJECT" = "null" ]; then
        print_error "Could not find any project after waiting"
        return 1
    fi
    
    PROJECT_ID=$(echo "$RECENT_PROJECT" | jq -r '.id // ""')
    PROJECT_NAME=$(echo "$RECENT_PROJECT" | jq -r '.name // ""')
    
    if [ -z "$PROJECT_ID" ] || [ -z "$PROJECT_NAME" ]; then
        print_error "Could not extract project details"
        return 1
    fi
    
    print_success "Project creation completed: $PROJECT_NAME (ID: $PROJECT_ID)"

    
    # Check blueprints
    print_status "Checking blueprint configurations..."
    
    BLUEPRINT_COUNT=$(aws datazone list-environment-blueprint-configurations \
        --region "$AWS_REGION" \
        --domain-identifier "$DOMAIN_ID" \
        --query 'length(items)' \
        --output text 2>/dev/null || echo "0")
    
    if [ "$BLUEPRINT_COUNT" -gt 0 ]; then
        print_success "Found $BLUEPRINT_COUNT blueprint configurations"
    else
        print_warning "No blueprint configurations found"
    fi
    
    # Check blueprint policy grants
    print_status "Checking blueprint policy grants..."
    
    ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
    GRANTS_FOUND=0
    
    # Check each blueprint type
    for BLUEPRINT_ID in "4k186sfh08eqxc" "ciw5fxhc6v6rio" "dlyaabb17hano0" "c9gx7j7bemrv0w"; do
        GRANT_COUNT=$(aws datazone list-policy-grants \
            --region "$AWS_REGION" \
            --domain-identifier "$DOMAIN_ID" \
            --entity-type ENVIRONMENT_BLUEPRINT_CONFIGURATION \
            --entity-identifier "$ACCOUNT_ID:$BLUEPRINT_ID" \
            --policy-type CREATE_ENVIRONMENT_FROM_BLUEPRINT \
            --query 'length(grantList)' \
            --output text 2>/dev/null || echo "0")
        
        if [ "$GRANT_COUNT" -gt 0 ]; then
            GRANTS_FOUND=$((GRANTS_FOUND + 1))
        fi
    done
    
    if [ "$GRANTS_FOUND" -gt 0 ]; then
        print_success "Found policy grants for $GRANTS_FOUND blueprints"
    else
        print_warning "No blueprint policy grants found"
    fi
    
    return 0
}

# Function to import project if it exists but not in state
import_project_if_needed() {
    print_status "Checking if project needs to be imported..."
    
    # Check if project resource exists in terraform state
    if terraform state show module.project.awscc_datazone_project.main &>/dev/null; then
        print_success "Project is already in terraform state"
        return 0
    fi
    
    # Get AWS region from terraform
    AWS_REGION=$(get_aws_region)
    
    # Get domain ID from terraform (this should always be available)
    DOMAIN_ID=$(terraform output -raw domain_id 2>/dev/null || echo "")
    
    if [ -z "$DOMAIN_ID" ]; then
        print_warning "Cannot import project - missing domain ID"
        return 1
    fi
    
    # Try to get project name from terraform output first
    PROJECT_NAME=$(terraform output -raw project_name 2>/dev/null || echo "")
    
    # If project name is not available from terraform, try to find it from AWS
    if [ -z "$PROJECT_NAME" ]; then
        print_status "Project name not available from Terraform outputs, searching AWS..."
        
        # Look for projects that match our expected naming pattern, sorted by creation date (most recent first)
        PROJECT_LIST=$(aws datazone list-projects \
            --region "$AWS_REGION" \
            --domain-identifier "$DOMAIN_ID" \
            --query 'items[?projectStatus==`ACTIVE`] | sort_by(@, &createdAt) | reverse(@) | [].{name:name,id:id,createdAt:createdAt}' \
            --output json 2>/dev/null || echo "[]")
        
        if [ "$(echo "$PROJECT_LIST" | jq length)" -eq 1 ]; then
            PROJECT_NAME=$(echo "$PROJECT_LIST" | jq -r '.[0].name')
            print_status "Found project in AWS: $PROJECT_NAME"
        elif [ "$(echo "$PROJECT_LIST" | jq length)" -gt 1 ]; then
            # Select the most recently created project
            PROJECT_NAME=$(echo "$PROJECT_LIST" | jq -r '.[0].name')
            PROJECT_COUNT=$(echo "$PROJECT_LIST" | jq length)
            print_status "Found $PROJECT_COUNT projects, selecting most recent: $PROJECT_NAME"
        else
            print_warning "No active projects found in domain"
            return 1
        fi
    fi
    
    if [ -z "$PROJECT_NAME" ]; then
        print_warning "Cannot import project - project name could not be determined"
        return 1
    fi
    
    # Wait for project to be fully active before attempting import
    if ! wait_for_project_creation "$DOMAIN_ID" "$AWS_REGION"; then
        print_warning "Project is not active, cannot import"
        return 1
    fi
    
    # Check if project exists in AWS
    PROJECT_INFO=$(aws datazone list-projects \
        --region "$AWS_REGION" \
        --domain-identifier "$DOMAIN_ID" \
        --query "items[?name=='$PROJECT_NAME']" \
        --output json 2>/dev/null || echo "[]")
    
    PROJECT_COUNT=$(echo "$PROJECT_INFO" | jq length 2>/dev/null || echo "0")
    
    if [ "$PROJECT_COUNT" -eq 0 ]; then
        print_warning "Project does not exist in AWS, cannot import"
        return 1
    fi
    
    PROJECT_ID=$(echo "$PROJECT_INFO" | jq -r '.[0].id' 2>/dev/null || echo "")
    PROJECT_STATUS=$(echo "$PROJECT_INFO" | jq -r '.[0].projectStatus' 2>/dev/null || echo "")
    
    if [ -z "$PROJECT_ID" ]; then
        print_warning "Could not get project ID, cannot import"
        return 1
    fi
    
    if [ "$PROJECT_STATUS" != "ACTIVE" ]; then
        print_warning "Project is not active (status: $PROJECT_STATUS), cannot import"
        return 1
    fi
    
    # For AWSCC DataZone projects, the import identifier format is: domain_id|project_id
    IMPORT_ID="${DOMAIN_ID}|${PROJECT_ID}"
    
    print_status "Importing project $PROJECT_ID (import ID: $IMPORT_ID) into terraform state..."
    
    # Attempt import once
    if terraform import module.project.awscc_datazone_project.main "$IMPORT_ID"; then
        print_success "Project imported successfully"
        return 0
    else
        print_warning "Import failed, but deployment may still be successful"
        return 1
    fi
}

# Function to display deployment summary
display_summary() {
    print_status "=== DEPLOYMENT SUMMARY ==="
    
    echo ""
    echo "🎯 SageMaker Unified Studio MVP Deployment"
    echo ""
    
    # Domain information
    DOMAIN_ID=$(terraform output -raw domain_id 2>/dev/null || echo "N/A")
    DOMAIN_URL=$(terraform output -raw domain_url 2>/dev/null || echo "N/A")
    
    echo "📊 Domain Information:"
    echo "   Domain ID: $DOMAIN_ID"
    echo "   Portal URL: $DOMAIN_URL"
    echo ""
    
    # Project information
    PROJECT_NAME=$(terraform output -raw project_name 2>/dev/null || echo "N/A")
    PROJECT_ID=$(terraform output -raw project_id 2>/dev/null || echo "N/A")
    
    echo "🚀 Project Information:"
    echo "   Project Name: $PROJECT_NAME"
    echo "   Project ID: $PROJECT_ID"
    echo ""
    
    # Blueprint information
    BLUEPRINT_COUNT=$(terraform output -raw blueprint_count 2>/dev/null || echo "0")
    ENABLED_BLUEPRINTS=$(terraform output -json enabled_blueprints 2>/dev/null | jq -r '.[]' | tr '\n' ', ' | sed 's/,$//' || echo "N/A")
    
    echo "🔧 Blueprint Information:"
    echo "   Enabled Blueprints: $ENABLED_BLUEPRINTS"
    echo "   Total Count: $BLUEPRINT_COUNT"
    echo ""
    
    # Next steps
    echo "Visit the SageMaker Unified Studio portal: $DOMAIN_URL"
    
    print_success "Deployment completed successfully!"
}

# Main execution
main() {
    print_status "Starting SageMaker Unified Studio MVP deployment..."
    echo ""
    
    # Check prerequisites
    check_aws_cli
    
    # Run terraform apply
    print_status "Running terraform apply..."
    echo ""
    
    # Pass all arguments to terraform apply
    if terraform apply "$@"; then
        TERRAFORM_SUCCESS=true
        print_success "Terraform apply completed successfully"
        
        # Wait for IAM role propagation after successful apply
        print_status "Waiting for IAM role propagation..."
        DOMAIN_ROLE_NAME="my-unified-studio-mvp-domain-execution-role"
        
        # Additional wait for AWS service propagation
        print_status "Waiting additional 30 seconds for AWS service propagation..."
        sleep 30
        
    else
        TERRAFORM_SUCCESS=false
        print_warning "Terraform apply encountered errors, but checking if resources were created..."
    fi
    
    echo ""
    
    # Validate deployment regardless of terraform exit code
    if validate_deployment; then
        DEPLOYMENT_SUCCESS=true
        print_success "Deployment validation passed"
        
        # Always try to import project if needed (it might have been created via CLI)
        import_project_if_needed
        
    else
        DEPLOYMENT_SUCCESS=false
        print_error "Deployment validation failed"
    fi
    
    echo ""
    
    # Display results
    if [ "$DEPLOYMENT_SUCCESS" = true ]; then
        display_summary
        
        # Run validation script if it exists
        if [ -f "./validate.sh" ]; then
            echo ""
            print_status "Running validation..."
            if ./validate.sh; then
                print_success "All validations passed!"
            else
                print_warning "Some validations failed, but deployment was successful"
            fi
        fi
        
        exit 0
    else
        print_error "Deployment failed validation. Please check the errors above."
        exit 1
    fi
}

# Run main function with all arguments
main "$@"
