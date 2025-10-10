# IAM Module Variables
# These variables control the creation and naming of IAM roles for SageMaker Unified Studio

variable "domain_name" {
  description = "Name of the SageMaker Unified Studio domain (used for role naming)"
  type        = string
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]$", var.domain_name))
    error_message = "Domain name must contain only alphanumeric characters and hyphens, and cannot start or end with a hyphen."
  }
}

variable "tags" {
  description = "Tags to apply to IAM resources"
  type        = map(string)
  default     = {}
  
  validation {
    condition     = length(var.tags) <= 50
    error_message = "Maximum of 50 tags allowed."
  }
}

# Domain Execution Role Configuration
variable "create_domain_execution_role" {
  description = "Whether to create the domain execution role (set to false if using existing role)"
  type        = bool
  default     = true
}

variable "domain_execution_role_name" {
  description = "Custom name for the domain execution role (if null, will use domain_name-domain-execution-role)"
  type        = string
  default     = null
}

variable "existing_domain_execution_role_arn" {
  description = "ARN of existing domain execution role (used when create_domain_execution_role is false)"
  type        = string
  default     = null
  
  validation {
    condition = var.existing_domain_execution_role_arn == null || can(regex("^arn:aws:iam::[0-9]{12}:role/.+", var.existing_domain_execution_role_arn))
    error_message = "Existing domain execution role ARN must be a valid IAM role ARN."
  }
}

# SageMaker Roles Configuration
variable "create_sagemaker_roles" {
  description = "Whether to create SageMaker-specific roles (manage access and provisioning)"
  type        = bool
  default     = true
}

variable "sagemaker_manage_access_role_name" {
  description = "Custom name for the SageMaker manage access role (if null, will use domain_name-sagemaker-manage-access-role)"
  type        = string
  default     = null
}

variable "existing_sagemaker_manage_access_role_arn" {
  description = "ARN of existing SageMaker manage access role (used when create_sagemaker_roles is false)"
  type        = string
  default     = null
  
  validation {
    condition = var.existing_sagemaker_manage_access_role_arn == null || can(regex("^arn:aws:iam::[0-9]{12}:role/.+", var.existing_sagemaker_manage_access_role_arn))
    error_message = "Existing SageMaker manage access role ARN must be a valid IAM role ARN."
  }
}

variable "sagemaker_provisioning_role_name" {
  description = "Custom name for the SageMaker provisioning role (if null, will use domain_name-sagemaker-provisioning-role)"
  type        = string
  default     = null
}

variable "existing_sagemaker_provisioning_role_arn" {
  description = "ARN of existing SageMaker provisioning role (used when create_sagemaker_roles is false)"
  type        = string
  default     = null
  
  validation {
    condition = var.existing_sagemaker_provisioning_role_arn == null || can(regex("^arn:aws:iam::[0-9]{12}:role/.+", var.existing_sagemaker_provisioning_role_arn))
    error_message = "Existing SageMaker provisioning role ARN must be a valid IAM role ARN."
  }
}
