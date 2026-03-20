#####################################################################################
# Create Project Policy Grant Module Variables
#####################################################################################

variable "domain_id" {
  description = "The ID of the DataZone domain."
  type        = string

  validation {
    condition     = can(regex("^dzd[-_][a-zA-Z0-9_-]{1,36}$", var.domain_id))
    error_message = "Domain ID must be in the format 'dzd_' or 'dzd-' followed by 1-36 alphanumeric characters."
  }
}

variable "project_profile_ids" {
  description = "List of project profile IDs to grant access to. All project profile IDs must be owned by the same domain unit and domain"
  type        = list(string)

  validation {
    condition     = length(var.project_profile_ids) > 0
    error_message = "At least one project profile ID must be provided."
  }
}

variable "include_child_domain_units" {
  description = "Specifies whether to include child domain units when creating a project from project profile policy grant details"
  type        = bool
  default     = true
}

# ── Principal variables ──────────────────────────────────────────────────────────

variable "user_principals" {
  description = "List of individual user identifiers to grant access to."
  type        = list(string)
  default     = []
}

variable "all_users" {
  description = "Whether to grant access to all users in the domain."
  type        = bool
  default     = false
}

variable "group_principals" {
  description = "List of group identifiers to grant access to."
  type        = list(string)
  default     = []
}
