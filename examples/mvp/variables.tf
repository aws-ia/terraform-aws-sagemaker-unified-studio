# Variables for SageMaker Unified Studio MVP Example
# This combines variables from both basic-domain and single-account-project examples

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
  default     = "terraform-mvp-domain-1"

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
  default     = "MVP SageMaker Unified Studio domain with complete project setup"
}

# Project Configuration
variable "project_name" {
  description = "Name of the project to create"
  type        = string
  default     = "terraform-mvp-project"

  validation {
    condition     = length(var.project_name) > 0 && length(var.project_name) <= 64
    error_message = "Project name must be between 1 and 64 characters."
  }
}

variable "project_description" {
  description = "Description of the project"
  type        = string
  default     = "MVP project created with Terraform for SageMaker Unified Studio"
}

# Blueprint Configuration
variable "enable_data_lake" {
  description = "Enable Default Data Lake blueprint (essential for data catalog and lake functionality)"
  type        = bool
  default     = true
}

variable "enable_redshift_serverless" {
  description = "Enable Default Data Warehouse blueprint (essential for analytics)"
  type        = bool
  default     = true
}

variable "enable_sagemaker" {
  description = "Enable Default SageMaker blueprint (essential for ML workloads)"
  type        = bool
  default     = true
}

variable "enable_custom_aws_service" {
  description = "Enable Custom AWS Service blueprint (optional for custom integrations)"
  type        = bool
  default     = false
}

# Environment and Tagging
variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "test"

  validation {
    condition     = contains(["dev", "staging", "prod", "test"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod, test."
  }
}

variable "owner" {
  description = "Owner of the domain (for tagging purposes)"
  type        = string
  default     = "terraform-validation"
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}