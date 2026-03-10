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

variable "domain_account_id" {
  description = "AWS account ID where the domain resides. Defaults to the current account. Set this for cross-account blueprints so IAM trust policies grant the domain account permission to assume roles."
  type        = string
  default     = null

  validation {
    condition     = var.domain_account_id == null || can(regex("^[0-9]{12}$", var.domain_account_id))
    error_message = "Account ID must be a 12-digit number."
  }
}

variable "create_manage_access_role" {
  description = "ARN of existing ManageAccess role. If not provided, the role is looked up or auto-created."
  type        = bool
  default     = true
}

variable "create_provisioning_role" {
  description = "ARN of existing Provisioning role. If not provided, the role is looked up or auto-created."
  type        = bool
  default     = true
}

variable "configure_lake_formation" {
  description = "Whether to configure Lake Formation data lake settings with admin permissions for SageMaker roles"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all resources created by this module"
  type        = map(string)
  default     = {}
}
