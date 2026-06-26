#####################################################################################
# Singular Project Profile Module
# Creates exactly one project profile per invocation.
# Tooling is always first (deployment_order = 0). Other ON_CREATE blueprints get
# deployment_order = 1; ON_DEMAND blueprints have no deployment order.
# Blueprint IDs are resolved internally by name via data source lookup.
#####################################################################################

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Data source needed to get root domain unit
data "aws_datazone_domain" "main" {
  id = var.domain_id
}

# Resolve blueprint IDs from names.
# Each entry's `blueprint` attribute is the managed blueprint name; the map key is
# only the environment configuration name. The blueprint ID is resolved here by name.
data "aws_datazone_environment_blueprint" "this" {
  for_each  = local.blueprint_names_to_lookup
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
  for_each = local.blueprint_ids
  id       = "${var.domain_id}|${each.value}${join("", var.blueprint_dependencies) == "" ? "" : ""}"
}

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.id

  # The managed blueprint NAME to look up for each entry. The map key is always the
  # environment configuration name; the blueprint is always taken from `blueprint`.
  lookup_names = {
    for name, bp in var.blueprints : name => bp.blueprint
  }

  # Tooling is added automatically and always resolves to the "Tooling" blueprint.
  tooling_lookup_name = "Tooling"

  # Unique set of blueprint names that require a data lookup (always include Tooling).
  blueprint_names_to_lookup = toset(concat([local.tooling_lookup_name], values(local.lookup_names)))

  # Resolved blueprint ID per configuration name (map key), via the name lookup.
  blueprint_ids = merge(
    {
      "Tooling" = data.aws_datazone_environment_blueprint.this[local.tooling_lookup_name].id
    },
    {
      for name, lk in local.lookup_names : name => data.aws_datazone_environment_blueprint.this[lk].id
      if name != "Tooling"
    }
  )

  # Non-tooling blueprints, ordered to match how Amazon DataZone stores and returns
  # environment configurations: ON_CREATE (deployment_order 1) before ON_DEMAND, each
  # group sorted alphabetically for stability.
  #
  # This ordering is important: the awscc provider correlates the API's computed values
  # (resolved parameter overrides, generated ids) back to the configured list entries
  # BY POSITION. DataZone groups configurations by deployment order, so if we sent them
  # in a different order (e.g. pure alphabetical) the provider would attribute one
  # configuration's parameter overrides to the wrong configuration — which previously
  # caused Redshift overrides to land on the QuickSight configuration and fail with
  # "parameter(s) are not present in the blueprint".
  non_tooling_on_create = sort([for name in keys(var.blueprints) : name if name != "Tooling" && var.blueprints[name].deployment_mode == "ON_CREATE"])
  non_tooling_on_demand = sort([for name in keys(var.blueprints) : name if name != "Tooling" && var.blueprints[name].deployment_mode == "ON_DEMAND"])
  non_tooling_names     = concat(local.non_tooling_on_create, local.non_tooling_on_demand)

  # Build environment_configurations: Tooling is always deployment_order 0, other
  # ON_CREATE blueprints are deployment_order 1, and ON_DEMAND blueprints have no
  # deployment order (omitted).
  environment_configurations = concat(
    # Tooling — always first, deployment_order 0
    [{
      name                     = "Tooling"
      environment_blueprint_id = local.blueprint_ids["Tooling"]
      // description and deployment mode always set by default
      description      = "Configuration for the Tooling"
      deployment_mode  = "ON_CREATE"
      deployment_order = 0
      aws_account = {
        aws_account_id = local.account_id
      }
      aws_region = {
        region_name = local.region
      }
      configuration_parameters = {
        # Always emit an explicit (possibly empty) list. parameter_overrides is
        # optional+computed; leaving it null makes Terraform retain stale computed
        # values from prior state, which causes one configuration's overrides to be
        # re-sent on the wrong configuration (e.g. glueDbName landing on a Bedrock
        # blueprint). An explicit list keeps each configuration's overrides correct.
        parameter_overrides = contains(keys(var.blueprints), "Tooling") ? [
          for k, v in var.blueprints["Tooling"].parameter_overrides : {
            name        = k
            value       = v.value
            is_editable = v.is_editable
          }
        ] : []
      }
    }],
    # Other blueprints — ON_CREATE gets deployment_order 1, ON_DEMAND has none
    [for name in local.non_tooling_names : {
      name                     = name
      environment_blueprint_id = local.blueprint_ids[name]
      description              = var.blueprints[name].description
      deployment_mode          = var.blueprints[name].deployment_mode
      deployment_order         = var.blueprints[name].deployment_mode == "ON_CREATE" ? 1 : null
      aws_account = {
        aws_account_id = local.account_id
      }
      aws_region = {
        region_name = var.blueprints[name].region != null ? var.blueprints[name].region : local.region
      }
      configuration_parameters = {
        # Always explicit (see Tooling note above) — empty list when no overrides.
        parameter_overrides = [
          for k, v in var.blueprints[name].parameter_overrides : {
            name        = k
            value       = v.value
            is_editable = v.is_editable
          }
        ]
      }
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