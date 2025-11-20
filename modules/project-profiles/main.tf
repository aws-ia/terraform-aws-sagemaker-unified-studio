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
        name = "Tooling"
        aws_account = {
          aws_account_id = data.aws_caller_identity.current.account_id
        }
        aws_region = {
          region_name = data.aws_region.current.id
        }
        environment_blueprint_id = var.tooling_id
        deployment_order         = 1
        deployment_mode          = "ON_CREATE"
      },

      var.enable_data_lake ? {
        name = "DataLake"
        aws_account = {
          aws_account_id = data.aws_caller_identity.current.account_id
        }
        aws_region = {
          region_name = data.aws_region.current.id
        }
        environment_blueprint_id = var.data_lake_id
        deployment_order         = 2
        deployment_mode          = "ON_CREATE"
      } : null,

      var.enable_redshift_serverless ? {
        name = "RedshiftServerless"
        aws_account = {
          aws_account_id = data.aws_caller_identity.current.account_id
        }
        aws_region = {
          region_name = data.aws_region.current.id
        }
        environment_blueprint_id = var.redshift_serverless_id
        deployment_order         = 3
        deployment_mode          = "ON_CREATE"
      } : null,

      var.enable_sagemaker ? {
        name = "SageMaker"
        aws_account = {
          aws_account_id = data.aws_caller_identity.current.account_id
        }
        aws_region = {
          region_name = data.aws_region.current.id
        }
        environment_blueprint_id = var.ml_experiments_id
        deployment_order         = 4
        deployment_mode          = "ON_CREATE"
      } : null
    ] : config if config != null
  ] : []
}

data "awscc_datazone_domain" "deployment_domain" {
  id = var.domain_id
}

resource "awscc_datazone_project_profile" "dynamic_project_profile" {
  count = var.enable_dynamic_profile ? 1 : 0
  name                       = var.dynamic_profile_name
  status                     = "ENABLED"
  domain_identifier          = var.domain_id
  environment_configurations = local.profile_config
}
/* The project profile seems to be enabled by default in my account - please double check and re-enable the following if this is not the case
resource "awscc_datazone_policy_grant" "project_profile_policy_grant" {
  count = var.enable_dynamic_profile ? 1 : 0
  domain_identifier = var.domain_id
  entity_type       = "DOMAIN_UNIT"
  entity_identifier = data.awscc_datazone_domain.deployment_domain.root_domain_unit_id
  policy_type       = "CREATE_PROJECT_FROM_PROJECT_PROFILE"
  detail = {
    create_project_from_project_profile = {
      include_child_domain_units = true
      project_profiles = [
        awscc_datazone_project_profile.dynamic_project_profile[0].project_profile_id
      ]
    }
  }
  principal = {
    user = {
      all_users_grant_filter = jsonencode({})
    }
  }
}
*/