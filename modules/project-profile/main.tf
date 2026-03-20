#####################################################################################
# Singular Project Profile Module
# Creates exactly one project profile per invocation.
# Tooling is always first (deployment_order = 1), other blueprints follow in
# alphabetical order starting at 2.
# Blueprint IDs are resolved internally by name via data source lookup.
#####################################################################################

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Data source needed to get root domain unit
data "aws_datazone_domain" "main" {
  id = var.domain_id
}

# Resolve blueprint IDs from names
data "aws_datazone_environment_blueprint" "this" {
  for_each  = toset(concat(["Tooling"], keys(var.blueprints)))
  domain_id = var.domain_id
  name      = each.key
  managed   = true
}

# Verify ALL referenced blueprints are configured (enabled) for this domain.
# Blueprint IDs always resolve (managed blueprints exist in every domain), but that
# does NOT mean they are configured with VPC, roles, and enabled regions.
# Without this check, a project profile could reference an unconfigured blueprint,
# causing environment creation failures at project time.
#
# The join() on blueprint_dependencies creates an implicit dependency so Terraform
# waits for blueprint modules to finish before reading configs.
data "awscc_datazone_environment_blueprint_configuration" "this" {
  for_each = data.aws_datazone_environment_blueprint.this
  id       = "${var.domain_id}|${each.value.id}${join("", var.blueprint_dependencies) == "" ? "" : ""}"
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
      // description and deployment mode always set by default
      description      = "Configuration for the Tooling"
      deployment_mode  = "ON_CREATE"
      deployment_order = 1
      aws_account = {
        aws_account_id = local.account_id
      }
      aws_region = {
        region_name = local.region
      }
      configuration_parameters = contains(keys(var.blueprints), "Tooling") && length(var.blueprints["Tooling"].parameter_overrides) > 0 ? {
        parameter_overrides = [
          for k, v in var.blueprints["Tooling"].parameter_overrides : {
            name        = k
            value       = v.value
            is_editable = v.is_editable
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
        region_name = var.blueprints[name].region != null ? var.blueprints[name].region : local.region
      }
      configuration_parameters = length(var.blueprints[name].parameter_overrides) > 0 ? {
        parameter_overrides = [
          for k, v in var.blueprints[name].parameter_overrides : {
            name        = k
            value       = v.value
            is_editable = v.is_editable
          }
        ]
      } : null
    }]
  )
  effective_domain_unit_id = var.domain_unit_id != null ? var.domain_unit_id : data.aws_datazone_domain.main.root_domain_unit_id
}

resource "awscc_datazone_project_profile" "this" {
  domain_identifier          = var.domain_id
  name                       = var.name
  description                = var.description
  status                     = var.status
  domain_unit_identifier     = local.effective_domain_unit_id
  environment_configurations = local.environment_configurations

  lifecycle {
    precondition {
      condition     = contains(data.awscc_datazone_environment_blueprint_configuration.this["Tooling"].enabled_regions, local.region)
      error_message = "Tooling blueprint is not configured for this domain in the current region (${local.region}). Enable the Tooling blueprint before creating a project profile."
    }

    precondition {
      condition = alltrue([
        for name in local.non_tooling_names :
        length(data.awscc_datazone_environment_blueprint_configuration.this[name].enabled_regions) > 0
      ])
      error_message = "One or more blueprints are not configured for this domain. Ensure all blueprints in var.blueprints are enabled via the blueprint module before creating a project profile."
    }
  }
}