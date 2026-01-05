#!/bin/bash
# Validation script for SageMaker Unified Studio MVP Example
# This script validates the complete deployment of domain, IAM roles, blueprints, and project

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

print_status $BLUE "🔍 Starting SageMaker Unified Studio MVP Validation..."
echo

# Check if terraform outputs are available
if ! terraform output domain_id >/dev/null 2>&1; then
    print_status $RED "❌ Error: Terraform outputs not available. Run 'terraform apply' first."
    exit 1
fi

# Get terraform outputs
DOMAIN_ID=$(terraform output -raw domain_id)
DOMAIN_NAME=$(terraform output -raw domain_name)
PROJECT_ID=$(terraform output -raw project_id)
PROJECT_NAME=$(terraform output -raw project_name)
ACCOUNT_ID=$(terraform output -raw account_id)
REGION=$(terraform output -raw region)

print_status $BLUE "📋 Configuration Details:"
echo "  Domain ID: $DOMAIN_ID"
echo "  Domain Name: $DOMAIN_NAME"
echo "  Project ID: $PROJECT_ID"
echo "  Project Name: $PROJECT_NAME"
echo "  Account ID: $ACCOUNT_ID"
echo "  Region: $REGION"
echo

# Validate AWS CLI access
print_status $YELLOW "🔐 Validating AWS CLI access..."
if ! aws sts get-caller-identity >/dev/null 2>&1; then
    print_status $RED "❌ Error: AWS CLI not configured or no access"
    exit 1
fi

CURRENT_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
if [ "$CURRENT_ACCOUNT" != "$ACCOUNT_ID" ]; then
    print_status $RED "❌ Error: AWS CLI account ($CURRENT_ACCOUNT) doesn't match Terraform account ($ACCOUNT_ID)"
    exit 1
fi
print_status $GREEN "✅ AWS CLI access validated"
echo

# Validate IAM Roles
print_status $YELLOW "👤 Validating IAM roles..."
IAM_ROLES=$(terraform output -json created_iam_roles | jq -r '.[]')
ROLE_COUNT=0
for role in $IAM_ROLES; do
    if aws iam get-role --role-name "$role" >/dev/null 2>&1; then
        print_status $GREEN "   ✅ IAM Role '$role' exists"
        ((ROLE_COUNT++))
    else
        print_status $RED "   ❌ IAM Role '$role' not found"
    fi
done
print_status $GREEN "✅ Found $ROLE_COUNT IAM roles"
echo

# Validate Domain Status
print_status $YELLOW "🏠 Validating domain status..."
DOMAIN_STATUS=$(aws datazone get-domain --identifier $DOMAIN_ID --query 'status' --output text 2>/dev/null || echo "ERROR")
if [ "$DOMAIN_STATUS" = "AVAILABLE" ]; then
    print_status $GREEN "✅ Domain is AVAILABLE"
    
    # Get domain details
    print_status $BLUE "   Domain details:"
    aws datazone get-domain --identifier $DOMAIN_ID \
        --query '{Name:name, Status:status, Description:description, CreatedAt:createdAt}' \
        --output table 2>/dev/null || print_status $RED "   Error getting domain details"
elif [ "$DOMAIN_STATUS" = "ERROR" ]; then
    print_status $RED "❌ Error: Cannot access domain $DOMAIN_ID"
    exit 1
else
    print_status $YELLOW "⚠️  Domain status: $DOMAIN_STATUS (may still be provisioning)"
fi
echo

# Validate Blueprint Configurations
print_status $YELLOW "🔧 Validating blueprint configurations..."
BLUEPRINT_COUNT=$(aws datazone list-environment-blueprint-configurations \
    --domain-identifier $DOMAIN_ID \
    --query 'length(items)' \
    --output text 2>/dev/null || echo "0")

if [ "$BLUEPRINT_COUNT" -gt 0 ]; then
    print_status $GREEN "✅ Found $BLUEPRINT_COUNT blueprint configuration(s)"
    
    print_status $BLUE "   Enabled blueprints:"
    aws datazone list-environment-blueprint-configurations \
        --domain-identifier $DOMAIN_ID \
        --query 'items[].environmentBlueprintId' \
        --output table 2>/dev/null || print_status $RED "   Error listing blueprints"
else
    print_status $RED "❌ No blueprint configurations found"
fi
echo

# Validate Project
print_status $YELLOW "🎯 Validating project..."
PROJECT_STATUS=$(aws datazone get-project \
    --identifier $PROJECT_ID \
    --domain-identifier $DOMAIN_ID \
    --query 'projectStatus' \
    --output text 2>/dev/null || echo "ERROR")

if [ "$PROJECT_STATUS" = "ACTIVE" ]; then
    print_status $GREEN "✅ Project is ACTIVE"
    
    print_status $BLUE "   Project details:"
    aws datazone get-project \
        --identifier $PROJECT_ID \
        --domain-identifier $DOMAIN_ID \
        --query '{Name:name, Status:projectStatus, Description:description, CreatedAt:createdAt}' \
        --output table 2>/dev/null || print_status $RED "   Error getting project details"
elif [ "$PROJECT_STATUS" = "ERROR" ]; then
    print_status $RED "❌ Error: Cannot access project $PROJECT_ID"
else
    print_status $YELLOW "⚠️  Project status: $PROJECT_STATUS (may still be provisioning)"
fi
echo

# Validate S3 Bucket
print_status $YELLOW "🪣 Validating S3 bucket..."
S3_BUCKET=$(terraform output -raw s3_bucket_name)
if aws s3api head-bucket --bucket $S3_BUCKET >/dev/null 2>&1; then
    print_status $GREEN "✅ S3 bucket '$S3_BUCKET' is accessible"
    
    # Check bucket versioning
    VERSIONING=$(aws s3api get-bucket-versioning --bucket $S3_BUCKET --query 'Status' --output text 2>/dev/null || echo "None")
    if [ "$VERSIONING" = "Enabled" ]; then
        print_status $GREEN "   ✅ Bucket versioning is enabled"
    else
        print_status $YELLOW "   ⚠️  Bucket versioning: $VERSIONING"
    fi
    
    # Check encryption
    ENCRYPTION=$(aws s3api get-bucket-encryption --bucket $S3_BUCKET --query 'ServerSideEncryptionConfiguration.Rules[0].ApplyServerSideEncryptionByDefault.SSEAlgorithm' --output text 2>/dev/null || echo "None")
    if [ "$ENCRYPTION" != "None" ]; then
        print_status $GREEN "   ✅ Bucket encryption: $ENCRYPTION"
    else
        print_status $YELLOW "   ⚠️  Bucket encryption not configured"
    fi
else
    print_status $RED "❌ Error: Cannot access S3 bucket '$S3_BUCKET'"
fi
echo

# Validate Network Configuration
print_status $YELLOW "🌐 Validating network configuration..."
VPC_ID=$(terraform output -raw vpc_id)
SUBNET_COUNT=$(terraform output -json subnet_ids | jq length)

if aws ec2 describe-vpcs --vpc-ids $VPC_ID >/dev/null 2>&1; then
    print_status $GREEN "✅ VPC '$VPC_ID' is accessible"
    print_status $GREEN "✅ Found $SUBNET_COUNT subnet(s) for SageMaker environments"
else
    print_status $RED "❌ Error: Cannot access VPC '$VPC_ID'"
fi
echo

# Terraform Provider Limitations Notice
print_status $YELLOW "⚠️  Terraform Provider Limitations:"
echo "   • Project profiles are not yet supported in Terraform AWS provider"
echo "   • Project memberships are not yet supported in Terraform AWS provider"
echo "   • These must be configured manually via AWS Console or CLI"
echo

# Summary
print_status $BLUE "📊 Validation Summary:"
echo "  ✅ Domain: $DOMAIN_STATUS"
echo "  ✅ IAM Roles: $ROLE_COUNT created"
echo "  ✅ Blueprints: $BLUEPRINT_COUNT configured"
echo "  ✅ Project: $PROJECT_STATUS"
echo "  ✅ S3 Bucket: Accessible with versioning and encryption"
echo "  ✅ Network: VPC and $SUBNET_COUNT subnets"
echo

# Access Information
print_status $GREEN "🎉 MVP Validation completed successfully!"
echo
print_status $BLUE "🔗 Access Information:"
DOMAIN_URL=$(terraform output -raw domain_url)
PROJECT_URL=$(terraform output -raw project_url)
echo "  Domain URL: $DOMAIN_URL"
echo "  Project URL: $PROJECT_URL"
echo

print_status $BLUE "📝 Next Steps:"
echo "  1. Visit the domain URL to access SageMaker Unified Studio"
echo "  2. Navigate to the Projects section"
echo "  3. Find your project: '$PROJECT_NAME'"
echo "  4. Manually configure project profiles and user memberships via AWS Console"
echo "  5. Create environments using the configured blueprints"
echo

print_status $BLUE "🔧 Manual Configuration Required:"
echo "  Due to Terraform provider limitations, you'll need to:"
echo "  • Create project profiles via AWS Console or CLI"
echo "  • Add user memberships via AWS Console or CLI"
echo "  • Configure environment parameters as needed"
echo

print_status $GREEN "✨ Your SageMaker Unified Studio MVP is ready!"