# SageMaker Unified Studio Project Module
# This module creates projects within a domain using a supplied project profile

# Data sources for current context
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Fetch the project profile to inspect its environment configurations.
# Used to determine whether the profile contains the ToolingLite blueprint,
# which requires a project_role to be supplied.
data "awscc_datazone_project_profile" "this" {
  id    = "${var.domain_id}|${var.project_profile_id}"
}

# Local values
locals {
  aws_region = var.aws_region != null ? var.aws_region : data.aws_region.current.id

  # Detect whether the resolved project profile uses the ToolingLite blueprint.
  # When true, var.project_role must be a valid IAM role ARN (bring-your-own-role).
  uses_tooling_lite = anytrue([
    for cfg in data.awscc_datazone_project_profile.this.environment_configurations :
    cfg.name == "ToolingLite"
  ])
}

# Main Project Resource using awscc provider
resource "awscc_datazone_project" "main" {
  domain_identifier = var.domain_id
  name              = var.project_name
  description       = var.project_description

  # Only set project_profile_id if it's provided and not empty
  project_profile_id = var.project_profile_id != null && var.project_profile_id != "" ? var.project_profile_id : null
  project_execution_role = var.project_role
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

    # Require a valid IAM role ARN when the project profile uses ToolingLite.
    # ToolingLite is a bring-your-own-role blueprint and the project will fail
    # to provision its environment without one.
    precondition {
      condition = !local.uses_tooling_lite || (
        var.project_role != null &&
        can(regex("^arn:aws[a-zA-Z-]*:iam::[0-9]{12}:role/.+$", var.project_role))
      )
      error_message = "The project profile '${var.project_profile_id}' includes the ToolingLite blueprint, which requires var.project_role to be set to a valid IAM role ARN (e.g. 'arn:aws:iam::123456789012:role/MyProjectRole')."
    }
  }
}