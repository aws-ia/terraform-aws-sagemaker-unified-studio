#####################################################################################
# Singular Blueprint Configuration Module Variables
# This module configures exactly one blueprint per invocation
#####################################################################################

variable "domain_id" {
  description = "The ID of the SageMaker Unified Studio domain"
  type        = string

  validation {
    condition     = can(regex("^dzd[-_][a-zA-Z0-9_-]{1,36}$", var.domain_id))
    error_message = "Domain ID must be in the format 'dzd_' or 'dzd-' followed by 1-36 alphanumeric characters, underscores, and hyphens."
  }
}

variable "blueprint_name" {
  description = "Name of the blueprint to configure (e.g., LakehouseCatalog, MLExperiments, RedshiftServerless). The blueprint ID is resolved internally via data lookup — if the name is invalid, the data source will fail with a clear error."
  type        = string
}

variable "domain_root_unit_id" {
  description = "The root domain unit ID for policy grants"
  type        = string
}

variable "allow_replace_existing" {
  description = "Allow replacing an existing blueprint configuration for this domain/account"
  type        = bool
  default     = false
}

variable "regional_parameters" {
  description = "Map of AWS regions to their infrastructure parameters (vpc_id, subnet_ids, s3_bucket_name). Keys become enabled_regions. Leave empty for blueprints that don't require regional parameters (e.g., QuickSight, Bedrock, MLflowApp, LakehouseAdmin)."
  type = map(object({
    vpc_id         = string
    subnet_ids     = list(string)
    s3_bucket_name = string
  }))
  default = {}

  validation {
    condition = alltrue([
      for region, params in var.regional_parameters : can(regex("^vpc-[a-z0-9]+$", params.vpc_id))
    ])
    error_message = "All vpc_id values must be in the format 'vpc-' followed by alphanumeric characters."
  }

  validation {
    condition = alltrue([
      for region, params in var.regional_parameters : alltrue([
        for subnet_id in params.subnet_ids : can(regex("^subnet-[a-z0-9]+$", subnet_id))
      ])
    ])
    error_message = "All subnet IDs must be in the format 'subnet-' followed by alphanumeric characters."
  }

  validation {
    condition = alltrue([
      for region, params in var.regional_parameters : length(params.subnet_ids) > 0
    ])
    error_message = "Each region must have at least one subnet_id."
  }

  validation {
    condition = alltrue([
      for region, params in var.regional_parameters : can(regex("^[a-z0-9][a-z0-9.-]*[a-z0-9]$", params.s3_bucket_name))
    ])
    error_message = "All s3_bucket_name values must be valid (lowercase letters, numbers, hyphens, and dots only)."
  }
}

variable "manage_access_role_arn" {
  description = "ARN of existing ManageAccess role. If not provided, the role is looked up or auto-created."
  type        = string
  default     = null

  validation {
    condition     = var.manage_access_role_arn == null || can(regex("^arn:aws:iam::[0-9]{12}:role/.+", var.manage_access_role_arn))
    error_message = "Manage access role ARN must be a valid IAM role ARN."
  }
}

variable "provisioning_role_arn" {
  description = "ARN of existing Provisioning role. If not provided, the role is looked up or auto-created."
  type        = string
  default     = null

  validation {
    condition     = var.provisioning_role_arn == null || can(regex("^arn:aws:iam::[0-9]{12}:role/.+", var.provisioning_role_arn))
    error_message = "Provisioning role ARN must be a valid IAM role ARN."
  }
}

variable "configure_lake_formation" {
  description = "Whether to configure Lake Formation data lake settings with admin permissions for SageMaker roles"
  type        = bool
  default     = true
}

variable "domain_execution_role_arn" {
  description = "ARN of the domain execution role to grant Lake Formation admin permissions"
  type        = string
  default     = null

  validation {
    condition     = var.domain_execution_role_arn == null || can(regex("^arn:aws:iam::[0-9]{12}:role/.+", var.domain_execution_role_arn))
    error_message = "Domain execution role ARN must be a valid IAM role ARN."
  }
}

variable "tags" {
  description = "Tags to apply to all resources created by this module"
  type        = map(string)
  default     = {}
}
