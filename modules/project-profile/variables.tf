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
    Map of blueprints to include in this project profile.
    Key = blueprint name (e.g., "Tooling", "DataLake", "RedshiftServerless") by default.

    By default the `blueprint` parameter is blank and the map key is used as the
    blueprint name to look up the blueprint ID via data source. If the optional
    `blueprint` parameter is set to a blueprint ID, that ID is used directly and the
    map key is treated only as the environment configuration name instead.

    Tooling must always be included and automatically gets deployment_order = 1.
    Note: For EmrOnEks, you must provide eksClusterArn in parameter_overrides.

    Example:
      blueprints = {
        # Resolved by name (key) — default behavior
        Tooling            = {}
        DataLake           = { region = "us-west-2", parameter_overrides = { glueDbName = { value = "my_db" } } }

        # Explicit blueprint ID — key "custom_redshift" becomes the configuration name
        custom_redshift = {
          blueprint       = "4lp8sfafm3rk6c"
          deployment_mode = "ON_DEMAND"
          region          = "eu-west-1"
          parameter_overrides = {
            redshiftBaseCapacity = { value = "256", is_editable = true }
          }
        }
      }
  EOT
  type = map(object({
    blueprint       = optional(string)
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
