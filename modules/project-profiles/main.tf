# SageMaker Unified Studio Project Profile Module
# This module creates project profiles with specific environment configurations
# Equivalent to cloudformation/domain/create_project_profiles.yaml (simplified)

# Data sources for current context
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Generate project profile configuration dynamically using blueprint IDs
locals {
  # Build the profile config dynamically based on enabled blueprints
  # Note: Tooling environment must be first (lowest deployment order) as other environments depend on it
  profile_config = var.enable_dynamic_profile ? [
    for config in [
      # Tooling environment - MUST be first with lowest deployment order
      {
        name                   = "Tooling"
        awsAccount = {
          awsAccountId = data.aws_caller_identity.current.account_id
        }
        awsRegion = {
          regionName = data.aws_region.current.id
        }
        environmentBlueprintId = var.tooling_id
        deploymentOrder = 1
      },
      
      var.enable_data_lake ? {
        name                   = "DataLake"
        awsAccount = {
          awsAccountId = data.aws_caller_identity.current.account_id
        }
        awsRegion = {
          regionName = data.aws_region.current.id
        }
        environmentBlueprintId = var.data_lake_id
        deploymentOrder = 2
      } : null,
      
      var.enable_redshift_serverless ? {
        name                   = "RedshiftServerless"
        awsAccount = {
          awsAccountId = data.aws_caller_identity.current.account_id
        }
        awsRegion = {
          regionName = data.aws_region.current.id
        }
        environmentBlueprintId = var.redshift_serverless_id
        deploymentOrder = 3
      } : null,
      
      var.enable_sagemaker ? {
        name                   = "SageMaker"
        awsAccount = {
          awsAccountId = data.aws_caller_identity.current.account_id
        }
        awsRegion = {
          regionName = data.aws_region.current.id
        }
        environmentBlueprintId = var.ml_experiments_id
        deploymentOrder = 4
      } : null
    ] : config if config != null
  ] : []
}

# Create the profile configuration file for dynamic profiles
resource "local_file" "profile_config" {
  count = var.enable_dynamic_profile ? 1 : 0
  
  content  = jsonencode(local.profile_config)
  filename = "${path.module}/profile-config.json"
}

# Create project profile using AWS CLI via local-exec for dynamic profiles
resource "null_resource" "dynamic_project_profile" {
  count = var.enable_dynamic_profile ? 1 : 0
  
  depends_on = [
    local_file.profile_config
  ]

  # Triggers to cache values for destroy-time provisioner
  # These will never actually trigger changes since they're static values
  triggers = {
    domain_id      = var.domain_id
    aws_region     = data.aws_region.current.id
    project_name   = var.dynamic_profile_name
    module_path    = path.module
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Check if project profile already exists
      echo "Checking for existing project profile: ${var.dynamic_profile_name}"
      EXISTING_PROFILE=$(aws datazone list-project-profiles \
        --domain-identifier ${var.domain_id} \
        --region ${data.aws_region.current.id} \
        --query 'items[?name==`${var.dynamic_profile_name}`].{id:id,status:status}' \
        --output json)
      
      if [ "$(echo $EXISTING_PROFILE | jq length)" -gt 0 ]; then
        echo "Project profile already exists, using existing profile"
        PROFILE_ID=$(echo $EXISTING_PROFILE | jq -r '.[0].id')
        PROFILE_STATUS=$(echo $EXISTING_PROFILE | jq -r '.[0].status')
        
        # Create output file with existing profile info
        echo "{\"id\":\"$PROFILE_ID\",\"status\":\"$PROFILE_STATUS\"}" > ${path.module}/project-profile-output.json
        
        # Ensure it's enabled
        if [ "$PROFILE_STATUS" != "ENABLED" ]; then
          echo "Enabling existing project profile: $PROFILE_ID"
          aws datazone update-project-profile \
            --domain-identifier ${var.domain_id} \
            --identifier $PROFILE_ID \
            --status ENABLED \
            --region ${data.aws_region.current.id}
        fi
      else
        echo "Creating new project profile"
        # Create the project profile
        aws datazone create-project-profile \
          --domain-identifier ${var.domain_id} \
          --name "${var.dynamic_profile_name}" \
          --description "Auto-generated project profile for ${var.dynamic_profile_name}" \
          --environment-configurations file://${path.module}/profile-config.json \
          --region ${data.aws_region.current.id} \
          --output json > ${path.module}/project-profile-output.json
        
        # Validate the output file was created successfully
        if [ ! -f "${path.module}/project-profile-output.json" ]; then
          echo "Error: Project profile output file was not created"
          exit 1
        fi
        
        # Validate the JSON content
        if ! jq empty ${path.module}/project-profile-output.json 2>/dev/null; then
          echo "Error: Invalid JSON in project profile output"
          cat ${path.module}/project-profile-output.json
          exit 1
        fi
        
        # Wait a moment for the profile to be fully created
        sleep 5
        
        # Enable the project profile immediately after creation
        PROFILE_ID=$(cat ${path.module}/project-profile-output.json | jq -r '.id // empty')
        if [ -z "$PROFILE_ID" ] || [ "$PROFILE_ID" = "null" ]; then
          echo "Error: Could not extract profile ID from output"
          cat ${path.module}/project-profile-output.json
          exit 1
        fi
        
        # Extract domain unit ID from the profile output
        DOMAIN_UNIT_ID=$(cat ${path.module}/project-profile-output.json | jq -r '.domainUnitId // empty')
        if [ -z "$DOMAIN_UNIT_ID" ] || [ "$DOMAIN_UNIT_ID" = "null" ]; then
          echo "Error: Could not extract domain unit ID from output"
          cat ${path.module}/project-profile-output.json
          exit 1
        fi
        
        echo "Enabling project profile: $PROFILE_ID in domain unit: $DOMAIN_UNIT_ID"
        aws datazone update-project-profile \
          --domain-identifier ${var.domain_id} \
          --identifier $PROFILE_ID \
          --status ENABLED \
          --region ${data.aws_region.current.id}
        
        # Wait for the profile to be fully enabled and ready
        echo "Waiting for project profile to be fully ready..."
        for i in {1..30}; do
          PROFILE_STATUS=$(aws datazone get-project-profile \
            --domain-identifier ${var.domain_id} \
            --identifier $PROFILE_ID \
            --region ${data.aws_region.current.id} \
            --query 'status' \
            --output text 2>/dev/null || echo "PENDING")
          
          if [ "$PROFILE_STATUS" = "ENABLED" ]; then
            echo "Project profile is ready (attempt $i/30)"
            break
          fi
          
          echo "Project profile status: $PROFILE_STATUS, waiting... (attempt $i/30)"
          sleep 2
        done
        
        if [ "$PROFILE_STATUS" != "ENABLED" ]; then
          echo "Warning: Project profile may not be fully ready, but continuing..."
        fi
        
        # Additional wait for environment configurations to be fully processed
        echo "Waiting additional time for environment configurations to be fully processed..."
        sleep 5
        
        echo "Project profile enabled successfully"
        
        # Remove any existing policy grants for old project profiles first
        echo "Cleaning up old policy grants..."
        aws datazone list-policy-grants \
          --domain-identifier ${var.domain_id} \
          --entity-identifier $DOMAIN_UNIT_ID \
          --entity-type DOMAIN_UNIT \
          --policy-type CREATE_PROJECT_FROM_PROJECT_PROFILE \
          --region ${data.aws_region.current.id} \
          --query 'grantList[].detail.createProjectFromProjectProfile.projectProfiles[]' \
          --output text | tr '\t' '\n' | while read old_profile_id; do
          if [ ! -z "$old_profile_id" ] && [ "$old_profile_id" != "None" ] && [ "$old_profile_id" != "$PROFILE_ID" ]; then
            echo "Removing old policy grant for profile: $old_profile_id"
            aws datazone remove-policy-grant \
              --domain-identifier ${var.domain_id} \
              --entity-identifier $DOMAIN_UNIT_ID \
              --entity-type DOMAIN_UNIT \
              --policy-type CREATE_PROJECT_FROM_PROJECT_PROFILE \
              --principal '{"user":{"allUsersGrantFilter":{}}}' \
              --region ${data.aws_region.current.id} || echo "Could not remove old policy grant"
          fi
        done
        
        # Add policy grant to authorize all users to create projects from this project profile
        echo "Adding policy grant to authorize project creation from profile: $PROFILE_ID"
        aws datazone add-policy-grant \
          --domain-identifier ${var.domain_id} \
          --entity-identifier $DOMAIN_UNIT_ID \
          --entity-type DOMAIN_UNIT \
          --policy-type CREATE_PROJECT_FROM_PROJECT_PROFILE \
          --principal '{"user":{"allUsersGrantFilter":{}}}' \
          --detail "{\"createProjectFromProjectProfile\":{\"projectProfiles\":[\"$PROFILE_ID\"]}}" \
          --region ${data.aws_region.current.id} || echo "Policy grant may already exist"
        
        echo "Policy grant added successfully"
      fi
    EOT
  }
}

# Extract project profile ID from the output for dynamic profiles
data "local_file" "dynamic_project_profile_output" {
  count = var.enable_dynamic_profile ? 1 : 0
  depends_on = [null_resource.dynamic_project_profile]
  filename   = "${path.module}/project-profile-output.json"
}

locals {
  # Safely parse the project profile ID with error handling
  dynamic_project_profile_id = var.enable_dynamic_profile ? try(jsondecode(data.local_file.dynamic_project_profile_output[0].content).id, null) : null
}
