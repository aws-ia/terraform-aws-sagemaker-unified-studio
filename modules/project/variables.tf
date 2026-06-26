# Project Module Variables

variable "domain_id" {
  description = "The ID of the SageMaker Unified Studio domain"
  type        = string
  
  validation {
    condition     = can(regex("^dzd[-_][a-zA-Z0-9_-]{1,36}$", var.domain_id))
    error_message = "Domain ID must be in the format 'dzd_' or 'dzd-' followed by 1-36 alphanumeric characters, underscores, and hyphens."
  }
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  
  validation {
    condition     = length(var.project_name) > 0 && length(var.project_name) <= 64
    error_message = "Project name must be between 1 and 64 characters."
  }
}

variable "project_description" {
  description = "Description of the project"
  type        = string
  default     = "SageMaker Unified Studio project created with Terraform"
  
  validation {
    condition     = length(var.project_description) <= 2048
    error_message = "Project description must be 2048 characters or less."
  }
}

variable "project_profile_id" {
  description = "ID of the project profile to use for this project (optional for V2 domains)"
  type        = string
  default     = null
  
  validation {
    condition     = var.project_profile_id == null || length(var.project_profile_id) > 0
    error_message = "Project profile ID must be either null or a non-empty string."
  }
}

variable "user_list" {
  description = "List of user identifiers to add as project owners"
  type        = list(string)
  default     = []
  
  validation {
    condition     = length(var.user_list) >= 0
    error_message = "User list must be a valid list (can be empty)."
  }
}

variable "contributor_list" {
  description = "List of user identifiers to add as project contributors"
  type        = list(string)
  default     = []
  
  validation {
    condition     = length(var.contributor_list) >= 0
    error_message = "Contributor list must be a valid list (can be empty)."
  }
}

variable "user_designation" {
  description = "Designation for users in the user_list"
  type        = string
  default     = "PROJECT_OWNER"
  
  validation {
    condition = contains([
      "PROJECT_OWNER",
      "PROJECT_CONTRIBUTOR"
    ], var.user_designation)
    error_message = "User designation must be either PROJECT_OWNER or PROJECT_CONTRIBUTOR."
  }
}

variable "user_parameters" {
  description = "User parameters for environment configurations"
  type = list(object({
    environment_configuration_name = string
    environment_parameters = list(object({
      name  = string
      value = string
    }))
  }))
  default = []
  
  validation {
    condition = alltrue([
      for param in var.user_parameters : length(param.environment_configuration_name) > 0
    ])
    error_message = "All environment configuration names must be non-empty."
  }
}

variable "aws_region" {
  description = "AWS region for API calls during cleanup"
  type        = string
  default     = null
  
  validation {
    condition     = var.aws_region == null || can(regex("^[a-z0-9-]+$", var.aws_region))
    error_message = "AWS region must be a valid region identifier."
  }
}

variable "tags" {
  description = "Tags to apply to the project"
  type        = map(string)
  default     = {}
}
