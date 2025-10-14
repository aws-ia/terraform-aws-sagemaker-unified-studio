# Project Profile Module Variables

variable "domain_id" {
  description = "The ID of the SageMaker Unified Studio domain"
  type        = string
  
  validation {
    condition     = can(regex("^dzd[_-][a-z0-9]+$", var.domain_id))
    error_message = "Domain ID must be in the format 'dzd_' or 'dzd-' followed by alphanumeric characters."
  }
}

# Profile Creation Flags
variable "create_basic_analytics_profile" {
  description = "Create basic analytics project profile"
  type        = bool
  default     = true
}

variable "create_ml_focused_profile" {
  description = "Create ML-focused project profile"
  type        = bool
  default     = false
}

variable "create_all_capabilities_profile" {
  description = "Create all capabilities project profile"
  type        = bool
  default     = false
}

# Dynamic Profile Configuration
variable "enable_dynamic_profile" {
  description = "Enable dynamic project profile creation using AWS CLI"
  type        = bool
  default     = false
}

variable "dynamic_profile_name" {
  description = "Name for the dynamic project profile"
  type        = string
  default     = "Dynamic Profile"
  
  validation {
    condition     = length(var.dynamic_profile_name) > 0 && length(var.dynamic_profile_name) <= 64
    error_message = "Profile name must be between 1 and 64 characters."
  }
}

variable "enable_data_lake" {
  description = "Enable Data Lake environment in dynamic profile"
  type        = bool
  default     = false
}

variable "enable_redshift_serverless" {
  description = "Enable Redshift Serverless environment in dynamic profile"
  type        = bool
  default     = false
}

variable "enable_sagemaker" {
  description = "Enable SageMaker environment in dynamic profile"
  type        = bool
  default     = false
}

# Profile Names
variable "basic_analytics_profile_name" {
  description = "Name for the basic analytics project profile"
  type        = string
  default     = "Basic Analytics Profile"
  
  validation {
    condition     = length(var.basic_analytics_profile_name) > 0 && length(var.basic_analytics_profile_name) <= 64
    error_message = "Profile name must be between 1 and 64 characters."
  }
}

variable "ml_focused_profile_name" {
  description = "Name for the ML-focused project profile"
  type        = string
  default     = "ML-Focused Profile"
  
  validation {
    condition     = length(var.ml_focused_profile_name) > 0 && length(var.ml_focused_profile_name) <= 64
    error_message = "Profile name must be between 1 and 64 characters."
  }
}

variable "all_capabilities_profile_name" {
  description = "Name for the all capabilities project profile"
  type        = string
  default     = "All Capabilities Profile"
  
  validation {
    condition     = length(var.all_capabilities_profile_name) > 0 && length(var.all_capabilities_profile_name) <= 64
    error_message = "Profile name must be between 1 and 64 characters."
  }
}

# Blueprint IDs (from blueprint module outputs)
variable "lakehouse_catalog_id" {
  description = "ID of the Lakehouse Catalog blueprint"
  type        = string
  default     = null
}

variable "tooling_id" {
  description = "ID of the Tooling blueprint"
  type        = string
  default     = null
}

variable "redshift_serverless_id" {
  description = "ID of the Redshift Serverless blueprint"
  type        = string
  default     = null
}

variable "ml_experiments_id" {
  description = "ID of the ML Experiments blueprint"
  type        = string
  default     = null
}

variable "data_lake_id" {
  description = "ID of the Data Lake blueprint"
  type        = string
  default     = null
}

variable "workflows_id" {
  description = "ID of the Workflows blueprint"
  type        = string
  default     = null
}

# Default Parameter Values
variable "default_glue_db_name" {
  description = "Default name for Glue database in Lakehouse configurations"
  type        = string
  default     = "default_glue_db"
  
  validation {
    condition     = can(regex("^[a-z][a-z0-9_]*$", var.default_glue_db_name))
    error_message = "Glue database name must start with a lowercase letter and contain only lowercase letters, numbers, and underscores."
  }
}

variable "default_redshift_db_name" {
  description = "Default name for Redshift database in Redshift configurations"
  type        = string
  default     = "default_redshift_db"
  
  validation {
    condition     = can(regex("^[a-z][a-z0-9_]*$", var.default_redshift_db_name))
    error_message = "Redshift database name must start with a lowercase letter and contain only lowercase letters, numbers, and underscores."
  }
}

variable "tags" {
  description = "Tags to apply to all project profiles"
  type        = map(string)
  default     = {}
}
