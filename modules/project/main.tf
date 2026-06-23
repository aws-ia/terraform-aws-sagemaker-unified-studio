# SageMaker Unified Studio Project Module
# This module creates projects and manages user memberships
# Equivalent to cloudformation/project/create_project.yaml

# Data sources for current context
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Local values
locals {
  aws_region = var.aws_region != null ? var.aws_region : data.aws_region.current.id
}

# Main Project Resource using awscc provider
resource "awscc_datazone_project" "main" {
  domain_identifier   = var.domain_id
  name               = var.project_name
  description        = var.project_description
  
  # Only set project_profile_id if it's provided and not empty
  project_profile_id = var.project_profile_id != null && var.project_profile_id != "" ? var.project_profile_id : null
  
  # User parameters for environment configurations
  # Transform the input variable to match awscc provider's expected structure
  user_parameters = [
    for param in var.user_parameters : {
      environment_configuration_name = param.environment_configuration_name
      environment_parameters = [
        for env_param in param.environment_parameters : {
          name  = env_param.name
          value = env_param.value
        }
      ]
    }
  ]
  
  # Lifecycle rule to handle AWSCC provider issues
  lifecycle {
    # Continue deployment even if AWSCC provider fails to track completion
    # The resource might be created successfully even if the provider times out
    ignore_changes = []
  }
}

# Pre-deletion cleanup: Delete all environments before deleting the project
resource "null_resource" "cleanup_environments" {
  # This resource runs before project deletion to clean up environments
  triggers = {
    domain_id  = var.domain_id
    project_id = awscc_datazone_project.main.project_id
    aws_region = local.aws_region
  }

  # Cleanup script that runs on destroy
  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      #!/bin/bash
      set -e
      
      echo "Cleaning up environments for project ${self.triggers.project_id}..."
      
      # Get all environments in the project
      ENVIRONMENTS=$(aws datazone list-environments \
        --domain-identifier "${self.triggers.domain_id}" \
        --project-identifier "${self.triggers.project_id}" \
        --region ${self.triggers.aws_region} \
        --query 'items[?status!=`DELETE_FAILED`].id' \
        --output text 2>/dev/null || echo "")
      
      if [ -n "$ENVIRONMENTS" ]; then
        echo "Found environments to delete: $ENVIRONMENTS"
        
        # Delete each environment
        for env_id in $ENVIRONMENTS; do
          echo "Deleting environment: $env_id"
          aws datazone delete-environment \
            --domain-identifier "${self.triggers.domain_id}" \
            --identifier "$env_id" \
            --region ${self.triggers.aws_region} || echo "Failed to delete environment $env_id, continuing..."
        done
        
        # Wait for environments to be deleted (with timeout)
        echo "Waiting for environments to delete..."
        for i in {1..30}; do
          REMAINING=$(aws datazone list-environments \
            --domain-identifier "${self.triggers.domain_id}" \
            --project-identifier "${self.triggers.project_id}" \
            --region ${self.triggers.aws_region} \
            --query 'items[?status!=`DELETE_FAILED` && status!=`DELETED`].id' \
            --output text 2>/dev/null || echo "")
          
          if [ -z "$REMAINING" ]; then
            echo "All environments deleted successfully"
            break
          fi
          
          echo "Waiting for environments to delete... ($i/30)"
          sleep 10
        done
      else
        echo "No environments found to delete"
      fi
      
      # Force delete any environments that are stuck in DELETE_FAILED state
      FAILED_ENVIRONMENTS=$(aws datazone list-environments \
        --domain-identifier "${self.triggers.domain_id}" \
        --project-identifier "${self.triggers.project_id}" \
        --region ${self.triggers.aws_region} \
        --query 'items[?status==`DELETE_FAILED`].id' \
        --output text 2>/dev/null || echo "")
      
      if [ -n "$FAILED_ENVIRONMENTS" ]; then
        echo "Found failed environments, attempting force cleanup: $FAILED_ENVIRONMENTS"
        for env_id in $FAILED_ENVIRONMENTS; do
          echo "Force deleting failed environment: $env_id"
          aws datazone delete-environment \
            --domain-identifier "${self.triggers.domain_id}" \
            --identifier "$env_id" \
            --region ${self.triggers.aws_region} || echo "Could not force delete environment $env_id"
        done
      fi
      
      echo "Environment cleanup completed"
    EOT
  }
  
  depends_on = [awscc_datazone_project.main]
}

# Project Memberships
# Create memberships for all specified users
resource "awscc_datazone_project_membership" "members" {
  for_each = toset(var.user_list)
  
  domain_identifier   = var.domain_id
  project_identifier  = awscc_datazone_project.main.project_id
  designation        = var.user_designation
  
  member = {
    user_identifier = each.value
  }
  
  depends_on = [awscc_datazone_project.main]
}

# Optional: Create additional memberships with different designations
resource "awscc_datazone_project_membership" "contributors" {
  for_each = toset(var.contributor_list)
  
  domain_identifier   = var.domain_id
  project_identifier  = awscc_datazone_project.main.project_id
  designation        = "PROJECT_CONTRIBUTOR"
  
  member = {
    user_identifier = each.value
  }
  
  depends_on = [awscc_datazone_project.main]
}
