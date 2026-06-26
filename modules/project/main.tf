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
