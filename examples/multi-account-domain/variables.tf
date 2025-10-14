# Variables for Multi-Account Domain Example
# These variables allow customization of the multi-account SageMaker Unified Studio domain deployment

# AWS Configuration
variable "aws_region" {
  description = "AWS region where the domain will be created"
  type        = string
  default     = "us-east-1"
  
  validation {
    condition = contains([
      "us-east-1", "us-east-2", "us-west-1", "us-west-2",
      "eu-west-1", "eu-west-2", "eu-central-1",
      "ap-southeast-1", "ap-southeast-2", "ap-northeast-1"
    ], var.aws_region)
    error_message = "AWS region must be one of the supported regions for SageMaker Unified Studio."
  }
}

# Domain Configuration
variable "domain_name" {
  description = "Name of the SageMaker Unified Studio domain"
  type        = string
  default     = "multi-account-unified-studio"
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]$", var.domain_name))
    error_message = "Domain name must contain only alphanumeric characters and hyphens, and cannot start or end with a hyphen."
  }
  
  validation {
    condition     = length(var.domain_name) >= 1 && length(var.domain_name) <= 64
    error_message = "Domain name must be between 1 and 64 characters long."
  }
}

variable "domain_description" {
  description = "Description of the SageMaker Unified Studio domain"
  type        = string
  default     = "Multi-account SageMaker Unified Studio domain created with Terraform"
}

variable "enable_sso" {
  description = "Enable AWS IAM Identity Center (SSO) integration"
  type        = bool
  default     = true
}

# Organization Configuration (matches CloudFormation OrganizationId parameter)
variable "organization_id" {
  description = "AWS Organizations ID for multi-account setup (required for organization-wide sharing)"
  type        = string
  
  validation {
    condition     = can(regex("^o-[a-z0-9]{10,32}$", var.organization_id))
    error_message = "Organization ID must be in the format 'o-xxxxxxxxxx'."
  }
}

variable "exclude_management_account" {
  description = "Whether to exclude the management account from resource sharing"
  type        = bool
  default     = true
}

variable "specific_account_ids" {
  description = "Specific list of account IDs to share with (overrides organization discovery if provided)"
  type        = list(string)
  default     = null
  
  validation {
    condition = var.specific_account_ids == null || alltrue([
      for account_id in var.specific_account_ids : can(regex("^[0-9]{12}$", account_id))
    ])
    error_message = "All account IDs must be 12-digit AWS account numbers."
  }
}

# Resource Sharing Configuration
variable "enable_resource_sharing" {
  description = "Whether to enable cross-account resource sharing"
  type        = bool
  default     = true
}

variable "exclude_current_account" {
  description = "Whether to exclude the current account from resource sharing"
  type        = bool
  default     = true
}

variable "allow_external_principals" {
  description = "Whether to allow sharing with external principals (outside organization)"
  type        = bool
  default     = false
}

variable "auto_accept_shares" {
  description = "Whether to automatically accept resource shares (for same organization)"
  type        = bool
  default     = true
}

# Environment and Tagging
variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod", "test"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod, test."
  }
}

variable "owner" {
  description = "Owner of the domain (for tagging purposes)"
  type        = string
  default     = "platform-team"
}
