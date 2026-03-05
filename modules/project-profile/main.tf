#####################################################################################
# Singular Project Profile Module
# Creates exactly one project profile per invocation.
# Tooling is always first (deployment_order = 1), other blueprints follow in
# alphabetical order starting at 2.
# Blueprint IDs are resolved internally by name via data source lookup.
#####################################################################################

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Resolve blueprint IDs from names
data "aws_datazone_environment_blueprint" "this" {
  for_each  = var.blueprints
  domain_id = var.domain_id
  name      = each.key
  managed   = true
}

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.id

  # Separate Tooling from other blueprints
  non_tooling_names = sort([for name in keys(var.blueprints) : name if name != "Tooling"])

  # Build environment_configurations: Tooling first (order 1), rest alphabetical (order 2+)
  environment_configurations = concat(
    # Tooling — always first
    [{
      name                     = "Tooling"
      environment_blueprint_id = data.aws_datazone_environment_blueprint.this["Tooling"].id
      description              = var.blueprints["Tooling"].description
      deployment_mode          = var.blueprints["Tooling"].deployment_mode
      deployment_order         = 1
      aws_account = {
        aws_account_id = local.account_id
      }
      aws_region = {
        region_name = local.region
      }
      configuration_parameters = length(var.blueprints["Tooling"].parameter_overrides) > 0 ? {
        parameter_overrides = [
          for k, v in var.blueprints["Tooling"].parameter_overrides : {
            name  = k
            value = v
          }
        ]
      } : null
    }],
    # Other blueprints — alphabetical order starting at 2
    [for idx, name in local.non_tooling_names : {
      name                     = name
      environment_blueprint_id = data.aws_datazone_environment_blueprint.this[name].id
      description              = var.blueprints[name].description
      deployment_mode          = var.blueprints[name].deployment_mode
      deployment_order         = idx + 2
      aws_account = {
        aws_account_id = local.account_id
      }
      aws_region = {
        region_name = local.region
      }
      configuration_parameters = length(var.blueprints[name].parameter_overrides) > 0 ? {
        parameter_overrides = [
          for k, v in var.blueprints[name].parameter_overrides : {
            name  = k
            value = v
          }
        ]
      } : null
    }]
  )
}

resource "awscc_datazone_project_profile" "this" {
  domain_identifier          = var.domain_id
  name                       = var.name
  description                = var.description
  status                     = var.status
  domain_unit_identifier     = var.domain_unit_id
  environment_configurations = local.environment_configurations
}
