variable "member_type" {
  description = "Type of project member. One of: SSO_USER, SSO_GROUP, IAM_USER, or IAM_ROLE."
  type        = string

  validation {
    condition     = contains(["SSO_USER", "SSO_GROUP", "IAM_USER", "IAM_ROLE"], var.member_type)
    error_message = "member_type must be one of: SSO_USER, SSO_GROUP, IAM_USER, IAM_ROLE."
  }
}

variable "identifier" {
  description = <<-EOT
    Identifier of the project member.
    - For member_type = "IAM_USER": full IAM user ARN
      (e.g. arn:aws:iam::123456789012:user/alice).
    - For member_type = "IAM_ROLE": full IAM role ARN
      (e.g. arn:aws:iam::123456789012:role/MyRole).
    - For member_type = "SSO_USER": identity store user ID (UUID) or SSO username.
    - For member_type = "SSO_GROUP": identity store group ID (UUID).
  EOT
  type        = string

  validation {
    condition     = length(trimspace(var.identifier)) > 0
    error_message = "identifier must be a non-empty string."
  }

  validation {
    # IAM_USER members must be a valid IAM user ARN.
    condition = var.member_type != "IAM_USER" || can(regex(
      "^arn:aws[a-zA-Z-]*:iam::[0-9]{12}:user/[\\w+=,.@/-]+$",
      var.identifier
    ))
    error_message = "When member_type is IAM_USER, identifier must be a valid IAM user ARN (e.g. arn:aws:iam::123456789012:user/alice)."
  }

  validation {
    # IAM_ROLE members must be a valid IAM role ARN.
    condition = var.member_type != "IAM_ROLE" || can(regex(
      "^arn:aws[a-zA-Z-]*:iam::[0-9]{12}:role/[\\w+=,.@/-]+$",
      var.identifier
    ))
    error_message = "When member_type is IAM_ROLE, identifier must be a valid IAM role ARN (e.g. arn:aws:iam::123456789012:role/MyRole)."
  }

  validation {
    # SSO_GROUP requires an identity store group UUID.
    condition = var.member_type != "SSO_GROUP" || can(regex(
      "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$",
      var.identifier
    ))
    error_message = "When member_type is SSO_GROUP, identifier must be an identity store group UUID (e.g. 12345678-1234-1234-1234-123456789012)."
  }
}

variable "project_role" {
  description = "Role of the user within the project. One of: PROJECT_OWNER, PROJECT_CONTRIBUTOR."
  type        = string
  default     = "PROJECT_CONTRIBUTOR"

  validation {
    condition     = contains(["PROJECT_OWNER", "PROJECT_CONTRIBUTOR"], var.project_role)
    error_message = "project_role must be either PROJECT_OWNER or PROJECT_CONTRIBUTOR."
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
