# Domain Module Variables
# These variables match the parameters in cloudformation/domain/create_domain.yaml

variable "domain_name" {
  description = "Name of the DataZone domain (matches CloudFormation DomainName parameter)"
  type        = string
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]$", var.domain_name))
    error_message = "Domain name must contain only alphanumeric characters and hyphens, and cannot start or end with a hyphen."
  }
  
  validation {
    condition     = length(var.domain_name) >= 1 && length(var.domain_name) <= 64
    error_message = "Domain name must be between 1 and 64 characters long."
  }
}

variable "description" {
  description = "Description of the domain"
  type        = string
  default     = "SageMaker Unified Studio domain managed by Terraform"
}

variable "domain_execution_role_arn" {
  description = "ARN of the IAM role for domain execution (matches CloudFormation DomainExecutionRole parameter)"
  type        = string
  
  validation {
    condition     = can(regex("^arn:aws:iam::[0-9]{12}:role/.+", var.domain_execution_role_arn))
    error_message = "Domain execution role ARN must be a valid IAM role ARN."
  }
}

variable "enable_sso" {
  description = "Enable AWS IAM Identity Center (SSO) integration (matches CloudFormation SingleSignOn configuration)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to the domain and related resources"
  type        = map(string)
  default     = {}
  
  validation {
    condition     = length(var.tags) <= 50
    error_message = "Maximum of 50 tags allowed."
  }
}
