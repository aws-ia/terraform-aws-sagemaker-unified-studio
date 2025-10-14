# Blueprint Configuration Module Variables

variable "domain_id" {
  description = "The ID of the SageMaker Unified Studio domain"
  type        = string
  
  validation {
    condition     = can(regex("^dzd[-_][a-zA-Z0-9_-]{1,36}$", var.domain_id))
    error_message = "Domain ID must be in the format 'dzd_' or 'dzd-' followed by 1-36 alphanumeric characters, underscores, and hyphens."
  }
}

variable "manage_access_role_arn" {
  description = "ARN of the IAM role to manage access to SageMaker environments"
  type        = string
  
  validation {
    condition     = can(regex("^arn:aws:iam::[0-9]{12}:role/.+", var.manage_access_role_arn))
    error_message = "Manage access role ARN must be a valid IAM role ARN."
  }
}

variable "provisioning_role_arn" {
  description = "ARN of the IAM role to provision SageMaker environments"
  type        = string
  
  validation {
    condition     = can(regex("^arn:aws:iam::[0-9]{12}:role/.+", var.provisioning_role_arn))
    error_message = "Provisioning role ARN must be a valid IAM role ARN."
  }
}

variable "s3_bucket_name" {
  description = "S3 bucket name for tooling environment storage"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.s3_bucket_name))
    error_message = "S3 bucket name must be valid (lowercase letters, numbers, and hyphens only)."
  }
}

variable "vpc_id" {
  description = "VPC ID for SageMaker environments"
  type        = string
  
  validation {
    condition     = can(regex("^vpc-[a-z0-9]+$", var.vpc_id))
    error_message = "VPC ID must be in the format 'vpc-' followed by alphanumeric characters."
  }
}

variable "subnet_ids" {
  description = "List of subnet IDs for SageMaker environments"
  type        = list(string)
  
  validation {
    condition     = length(var.subnet_ids) > 0
    error_message = "At least one subnet ID must be provided."
  }
  
  validation {
    condition = alltrue([
      for subnet_id in var.subnet_ids : can(regex("^subnet-[a-z0-9]+$", subnet_id))
    ])
    error_message = "All subnet IDs must be in the format 'subnet-' followed by alphanumeric characters."
  }
}

# Blueprint Enable/Disable Flags
variable "enable_tooling" {
  description = "Enable Tooling blueprint (required for other environments to work)"
  type        = bool
  default     = true
}

variable "enable_data_lake" {
  description = "Enable Default Data Lake blueprint (essential for data catalog and lake functionality)"
  type        = bool
  default     = true
}

variable "enable_redshift_serverless" {
  description = "Enable Default Data Warehouse blueprint (essential for analytics)"
  type        = bool
  default     = true
}

variable "enable_sagemaker" {
  description = "Enable Default SageMaker blueprint (essential for ML workloads)"
  type        = bool
  default     = true
}

variable "enable_custom_aws_service" {
  description = "Enable Custom AWS Service blueprint (optional for custom integrations)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to all blueprint configurations"
  type        = map(string)
  default     = {}
}