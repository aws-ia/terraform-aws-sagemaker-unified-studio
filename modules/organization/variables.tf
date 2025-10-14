# Organization Module Variables
# These variables control AWS Organizations integration and account discovery

variable "organization_id" {
  description = "AWS Organizations ID for multi-account setup (matches CloudFormation OrganizationId parameter)"
  type        = string
  default     = null
  
  validation {
    condition = var.organization_id == null || can(regex("^o-[a-z0-9]{10,32}$", var.organization_id))
    error_message = "Organization ID must be in the format 'o-xxxxxxxxxx' or null to disable organization integration."
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

variable "account_name_filter" {
  description = "Optional regex pattern to filter accounts by name"
  type        = string
  default     = null
}

variable "account_email_filter" {
  description = "Optional regex pattern to filter accounts by email"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to organization-related resources"
  type        = map(string)
  default     = {}
}
