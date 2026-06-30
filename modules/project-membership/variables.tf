
# Principal grouping used by the membership wiring. Each variable accepts any
# combination of SSO users, SSO groups, IAM users, and IAM roles. Empty lists
# are fine.
#
# - project_owners       : added to the created project as PROJECT_OWNER
# - project_contributors : added to the created project as PROJECT_CONTRIBUTOR
variable "project_owners" {
  description = "Principals to add to the created project as PROJECT_OWNER."
  type = object({
    sso_users  = optional(list(string), [])
    sso_groups = optional(list(string), [])
    iam_users  = optional(list(string), [])
    iam_roles  = optional(list(string), [])
  })
  default = {}

  validation {
    # Every SSO user identifier must be a non-empty string.
    condition     = alltrue([for u in var.project_owners.sso_users : length(trimspace(u)) > 0])
    error_message = "Each project_owners.sso_users entry must be a non-empty string."
  }

  validation {
    # Each SSO group requires an identity store group UUID.
    condition = alltrue([for g in var.project_owners.sso_groups : can(regex(
      "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$",
      g
    ))])
    error_message = "Each project_owners.sso_groups entry must be an identity store group UUID (e.g. 12345678-1234-1234-1234-123456789012)."
  }

  validation {
    # Each IAM user must be a valid IAM user ARN.
    condition = alltrue([for a in var.project_owners.iam_users : can(regex(
      "^arn:aws[a-zA-Z-]*:iam::[0-9]{12}:user/[\\w+=,.@/-]+$",
      a
    ))])
    error_message = "Each project_owners.iam_users entry must be a valid IAM user ARN (e.g. arn:aws:iam::123456789012:user/alice)."
  }

  validation {
    # Each IAM role must be a valid IAM role ARN.
    condition = alltrue([for a in var.project_owners.iam_roles : can(regex(
      "^arn:aws[a-zA-Z-]*:iam::[0-9]{12}:role/[\\w+=,.@/-]+$",
      a
    ))])
    error_message = "Each project_owners.iam_roles entry must be a valid IAM role ARN (e.g. arn:aws:iam::123456789012:role/MyRole)."
  }
}

variable "project_contributors" {
  description = "Principals to add to the created project as PROJECT_CONTRIBUTOR."
  type = object({
    sso_users  = optional(list(string), [])
    sso_groups = optional(list(string), [])
    iam_users  = optional(list(string), [])
    iam_roles  = optional(list(string), [])
  })
  default = {}

  validation {
    # Every SSO user identifier must be a non-empty string.
    condition     = alltrue([for u in var.project_contributors.sso_users : length(trimspace(u)) > 0])
    error_message = "Each project_contributors.sso_users entry must be a non-empty string."
  }

  validation {
    # Each SSO group requires an identity store group UUID.
    condition = alltrue([for g in var.project_contributors.sso_groups : can(regex(
      "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$",
      g
    ))])
    error_message = "Each project_contributors.sso_groups entry must be an identity store group UUID (e.g. 12345678-1234-1234-1234-123456789012)."
  }

  validation {
    # Each IAM user must be a valid IAM user ARN.
    condition = alltrue([for a in var.project_contributors.iam_users : can(regex(
      "^arn:aws[a-zA-Z-]*:iam::[0-9]{12}:user/[\\w+=,.@/-]+$",
      a
    ))])
    error_message = "Each project_contributors.iam_users entry must be a valid IAM user ARN (e.g. arn:aws:iam::123456789012:user/alice)."
  }

  validation {
    # Each IAM role must be a valid IAM role ARN.
    condition = alltrue([for a in var.project_contributors.iam_roles : can(regex(
      "^arn:aws[a-zA-Z-]*:iam::[0-9]{12}:role/[\\w+=,.@/-]+$",
      a
    ))])
    error_message = "Each project_contributors.iam_roles entry must be a valid IAM role ARN (e.g. arn:aws:iam::123456789012:role/MyRole)."
  }
}

variable "project_id" {
  description = "ID of the SageMaker Unified Studio project to add the member to."
  type        = string

  validation {
    condition     = length(trimspace(var.project_id)) > 0
    error_message = "project_id must be a non-empty string."
  }
}

variable "domain_id" {
  description = "ID of the SageMaker Unified Studio domain that owns the project."
  type        = string

  validation {
    condition     = can(regex("^dzd[-_][a-zA-Z0-9_-]{1,36}$", var.domain_id))
    error_message = "domain_id must be in the format 'dzd_' or 'dzd-' followed by 1-36 alphanumeric characters, underscores, or hyphens."
  }
}
