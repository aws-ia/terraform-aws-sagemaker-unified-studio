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

variable "has_regional_parameters" {
  description = "Whether this blueprint requires regional parameters (VPC, subnets, S3). Set to false for blueprints like QuickSight, Bedrock, MLflowApp, LakehouseAdmin."
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "VPC ID for blueprint regional parameters. Required when has_regional_parameters is true."
  type        = string
  default     = null

  validation {
    condition     = var.vpc_id == null || can(regex("^vpc-[a-z0-9]+$", var.vpc_id))
    error_message = "VPC ID must be in the format 'vpc-' followed by alphanumeric characters."
  }
}

variable "subnet_ids" {
  description = "List of subnet IDs for blueprint regional parameters. Required when has_regional_parameters is true."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for subnet_id in var.subnet_ids : can(regex("^subnet-[a-z0-9]+$", subnet_id))
    ])
    error_message = "All subnet IDs must be in the format 'subnet-' followed by alphanumeric characters."
  }
}

variable "s3_bucket_name" {
  description = "S3 bucket name for blueprint storage. Required when has_regional_parameters is true."
  type        = string
  default     = null

  validation {
    condition     = var.s3_bucket_name == null || can(regex("^[a-z0-9][a-z0-9.-]*[a-z0-9]$", var.s3_bucket_name))
    error_message = "S3 bucket name must be valid (lowercase letters, numbers, hyphens, and dots only)."
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

variable "enabled_regions" {
  description = "List of AWS regions to enable the blueprint in. Defaults to current region."
  type        = list(string)
  default     = null
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
