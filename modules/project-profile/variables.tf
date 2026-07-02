#####################################################################################
# Singular Project Profile Module Variables
# Creates exactly one project profile per invocation
#####################################################################################

variable "domain_id" {
  description = "The ID of the SageMaker Unified Studio domain"
  type        = string

  validation {
    condition     = can(regex("^dzd[-_][a-zA-Z0-9_-]{1,36}$", var.domain_id))
    error_message = "Domain ID must be in the format 'dzd_' or 'dzd-' followed by 1-36 alphanumeric characters."
  }
}

variable "name" {
  description = "Name of the project profile"
  type        = string

  validation {
    condition     = length(var.name) >= 1 && length(var.name) <= 64
    error_message = "Profile name must be between 1 and 64 characters."
  }
}

variable "description" {
  description = "Description of the project profile"
  type        = string
  default     = null
}

variable "status" {
  description = "Status of the project profile (ENABLED or DISABLED)"
  type        = string
  default     = "ENABLED"

  validation {
    condition     = contains(["ENABLED", "DISABLED"], var.status)
    error_message = "Status must be ENABLED or DISABLED."
  }
}

variable "domain_unit_id" {
  description = "The domain unit ID that owns the project profile. If not provided, the module will use the root domain unit."
  type        = string
  default     = null
}

variable "blueprints" {
  description = <<-EOT
    Map of environment configurations to include in this project profile.

    Key = the environment configuration name (e.g., "OnDemand Redshift Serverless").
    `blueprint` (required) = the managed blueprint name to resolve to a blueprint ID
    via data lookup (e.g., "RedshiftServerless", "DataLake", "QuickSight").

    The map key is always treated as the configuration name only; the blueprint is
    always resolved from the `blueprint` attribute. This allows multiple configurations
    to reference the same blueprint (e.g., an ON_CREATE and an ON_DEMAND Redshift).

    Tooling is added automatically (deployment_order = 0) and does not need an entry.
    Note: For EmrOnEks, you must provide eksClusterArn in parameter_overrides.

    Example:
      blueprints = {
        "Lakehouse Database" = {
          blueprint       = "DataLake"
          deployment_mode = "ON_CREATE"
          parameter_overrides = { glueDbName = { value = "glue_db", is_editable = true } }
        }
        "OnDemand Redshift Serverless" = {
          blueprint       = "RedshiftServerless"
          deployment_mode = "ON_DEMAND"
          region          = "eu-west-1"
          parameter_overrides = {
            redshiftBaseCapacity = { value = "256", is_editable = true }
          }
        }
      }
  EOT
  type = map(object({
    blueprint       = string
    description     = optional(string)
    deployment_mode = optional(string, "ON_CREATE")
    region          = optional(string)
    parameter_overrides = optional(map(object({
      value       = string
      is_editable = optional(bool, false)
    })), {})
  }))


  validation {
    condition = alltrue([
      for name, bp in var.blueprints : bp.blueprint != null && bp.blueprint != ""
    ])
    error_message = "Each entry must set a non-empty `blueprint` (the managed blueprint name to look up)."
  }

  validation {
    condition = alltrue([
      for name, bp in var.blueprints : contains(["ON_CREATE", "ON_DEMAND"], bp.deployment_mode)
    ])
    error_message = "deployment_mode must be ON_CREATE or ON_DEMAND."
  }

  validation {
    condition = !contains(keys(var.blueprints), "EmrOnEks") || contains(
      keys(try(var.blueprints["EmrOnEks"].parameter_overrides, {})),
      "eksClusterArn"
    )
    error_message = "eksClusterArn is required in parameter_overrides when using EmrOnEks blueprint."
  }
}

variable "blueprint_dependencies" {
  description = "List of blueprint entity IDs to ensure they are created before the profile. Pass the entity_id output from each blueprint module. This prevents race conditions when blueprints and profiles are deployed in the same apply."
  type        = list(string)
  default     = []
}
