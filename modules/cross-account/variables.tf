variable "domain_id" {
  description = "The ID of the SageMaker Unified Studio domain"
  type        = string

  validation {
    condition     = can(regex("^dzd[-_][a-zA-Z0-9_-]{1,36}$", var.domain_id))
    error_message = "Domain ID must be in the format 'dzd_' or 'dzd-' followed by 1-36 alphanumeric characters, underscores, and hyphens."
  }
}

variable "using_organizations" {
  description = "Set to true if both the domain account (source account) and the account to be associated (destination account) are in an AWS organization. This will skip a manual resource share accepter step."
  type        = bool
  default     = false
}
