#####################################################################################
# Singular Blueprint Configuration Module Variables
# Creates exactly one blueprint configuration per invocation
#####################################################################################

variable "domain_id" {
  description = "The DataZone domain ID"
  type        = string

  validation {
    condition     = can(regex("^dzd[-_][a-zA-Z0-9_-]{1,36}$", var.domain_id))
    error_message = "Domain ID must match format dzd-xxx or dzd_xxx."
  }
}

variable "blueprint_name" {
  description = "Name of the blueprint to configure (e.g., LakehouseCatalog, MLExperiments, RedshiftServerless)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for regional parameters"
  type        = string

  validation {
    condition     = can(regex("^vpc-[a-z0-9]+$", var.vpc_id))
    error_message = "VPC ID must match pattern vpc-xxx."
  }
}

variable "subnet_ids" {
  description = "Subnet IDs for regional parameters"
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) > 0
    error_message = "At least one subnet ID required."
  }

  validation {
    condition     = alltrue([for s in var.subnet_ids : can(regex("^subnet-[a-z0-9]+$", s))])
    error_message = "All subnet IDs must match pattern subnet-xxx."
  }
}

variable "s3_bucket_name" {
  description = "S3 bucket name for blueprint storage"
  type        = string
}

variable "domain_root_unit_id" {
  description = "Root domain unit ID for policy grants"
  type        = string
}

variable "manage_access_role_arn" {
  description = "ARN of existing ManageAccess role. If not provided, the role is auto-created."
  type        = string
  default     = null

  validation {
    condition     = var.manage_access_role_arn == null || can(regex("^arn:aws:iam::[0-9]{12}:role/.+", var.manage_access_role_arn))
    error_message = "Must be a valid IAM role ARN."
  }
}

variable "provisioning_role_arn" {
  description = "ARN of existing Provisioning role. If not provided, defaults to AmazonSageMakerProvisioning-<accountId>."
  type        = string
  default     = null

  validation {
    condition     = var.provisioning_role_arn == null || can(regex("^arn:aws:iam::[0-9]{12}:role/.+", var.provisioning_role_arn))
    error_message = "Must be a valid IAM role ARN."
  }
}

variable "allow_replace_existing" {
  description = "Allow replacing an existing blueprint configuration for this domain/account"
  type        = bool
  default     = false
}

variable "enabled_regions" {
  description = "List of AWS regions to enable the blueprint in. Defaults to current region."
  type        = list(string)
  default     = null
}

variable "configure_lake_formation" {
  description = "Whether to configure Lake Formation admin permissions"
  type        = bool
  default     = true
}

variable "domain_execution_role_arn" {
  description = "Domain execution role ARN for Lake Formation admin"
  type        = string
  default     = null

  validation {
    condition     = var.domain_execution_role_arn == null || can(regex("^arn:aws:iam::[0-9]{12}:role/.+", var.domain_execution_role_arn))
    error_message = "Must be a valid IAM role ARN."
  }
}

variable "tags" {
  description = "Tags to apply to created resources"
  type        = map(string)
  default     = {}
}
