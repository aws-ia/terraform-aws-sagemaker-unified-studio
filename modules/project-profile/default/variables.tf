variable "domain_id" {
  description = "The ID of the SageMaker Unified Studio domain"
  type        = string

  validation {
    condition     = can(regex("^dzd[-_][a-zA-Z0-9_-]{1,36}$", var.domain_id))
    error_message = "Domain ID must be in the format 'dzd_' or 'dzd-' followed by 1-36 alphanumeric characters."
  }
}

variable "provisioning_role_arn" {
  description = "ARN of existing Provisioning role. If not provided, the role is looked up by name. If neither is found, the module will fail — use the bootstrap submodule to create roles first."
  type        = string
  default     = null

  validation {
    condition     = var.provisioning_role_arn == null || can(regex("^arn:aws:iam::[0-9]{12}:role/.+", var.provisioning_role_arn))
    error_message = "Provisioning role ARN must be a valid IAM role ARN."
  }
}

variable "using_admin_project" {
  description = "Set to true if an admin project is used. The admin project's execution role acts as provisioner for the ToolingLite, S3Bucket, and S3TableCatalog blueprints, so var.provisioning_role_arn is ignored."
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "VPC ID to attach to the ToolingLite blueprint configuration. Must be provided together with subnet_ids. When both are set, the ToolingLite blueprint is enabled with the same VPC/Subnets regional parameters used by the standard Tooling blueprint."
  type        = string
  default     = null

  validation {
    condition     = var.vpc_id == null || can(regex("^vpc-[a-z0-9]+$", var.vpc_id))
    error_message = "vpc_id must be a valid VPC identifier (e.g. vpc-0abc1234)."
  }
}

variable "subnet_ids" {
  description = "Subnet IDs to attach to the ToolingLite blueprint configuration. Must be provided together with vpc_id. All subnets must belong to vpc_id."
  type        = list(string)
  default     = null

  validation {
    condition     = var.subnet_ids == null || alltrue([for s in coalesce(var.subnet_ids, []) : can(regex("^subnet-[a-z0-9]+$", s))])
    error_message = "Each entry in subnet_ids must be a valid subnet identifier (e.g. subnet-0abc1234)."
  }

  validation {
    condition     = var.subnet_ids == null || length(coalesce(var.subnet_ids, [])) > 0
    error_message = "subnet_ids must contain at least one subnet when provided."
  }
}

# Cross-variable validation lives in main.tf as a precondition because Terraform
# variable validation can't reference other variables.
