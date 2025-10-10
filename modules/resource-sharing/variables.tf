# Resource Sharing Module Variables
# These variables control AWS RAM resource sharing for SageMaker Unified Studio domain

# Domain information (required)
variable "domain_id" {
  description = "SageMaker Unified Studio domain ID (matches CloudFormation DomainId parameter)"
  type        = string
  
  validation {
    condition     = can(regex("^dzd_[a-z0-9]+$", var.domain_id))
    error_message = "Domain ID must be in the format 'dzd_xxxxxxxxxx'."
  }
}

variable "domain_arn" {
  description = "SageMaker Unified Studio domain ARN (matches CloudFormation DomainARN parameter)"
  type        = string
  
  validation {
    condition     = can(regex("^arn:aws:datazone:[a-z0-9-]+:[0-9]{12}:domain/dzd_[a-z0-9]+$", var.domain_arn))
    error_message = "Domain ARN must be a valid DataZone domain ARN."
  }
}

variable "domain_name" {
  description = "SageMaker Unified Studio domain name (matches CloudFormation DomainName parameter)"
  type        = string
  
  validation {
    condition     = length(var.domain_name) > 0 && length(var.domain_name) <= 64
    error_message = "Domain name must be between 1 and 64 characters."
  }
}

# Account sharing configuration
variable "account_ids" {
  description = "List of AWS account IDs to share the domain with (matches CloudFormation AccountsForResourceShare parameter)"
  type        = list(string)
  
  validation {
    condition = alltrue([
      for account_id in var.account_ids : can(regex("^[0-9]{12}$", account_id))
    ])
    error_message = "All account IDs must be 12-digit AWS account numbers."
  }
}

variable "exclude_current_account" {
  description = "Whether to exclude the current account from resource sharing"
  type        = bool
  default     = true
}

# Resource share configuration
variable "enable_resource_sharing" {
  description = "Whether to enable resource sharing (allows conditional sharing)"
  type        = bool
  default     = true
}

variable "resource_share_name" {
  description = "Custom name for the resource share (if null, will use DataZone-{domain_name}-{domain_id})"
  type        = string
  default     = null
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

# Tagging
variable "tags" {
  description = "Tags to apply to resource sharing resources"
  type        = map(string)
  default     = {}
  
  validation {
    condition     = length(var.tags) <= 50
    error_message = "Maximum of 50 tags allowed."
  }
}
