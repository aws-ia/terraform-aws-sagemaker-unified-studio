# Variables for SageMaker Unified Studio Quick-Setup Example
# Demonstrates the new modular architecture with domain, blueprint, and project profile modules

#####################################################################################
# AWS Configuration
#####################################################################################

variable "aws_region" {
  description = "AWS region where the domain will be created"
  type        = string
  default     = "us-east-1"

  validation {
    condition = contains([
      "us-east-1",      # US East (N. Virginia)
      "us-east-2",      # US East (Ohio)
      "us-west-2",      # US West (Oregon)
      "ca-central-1",   # Canada (Central)
      "sa-east-1",      # South America (São Paulo)
      "eu-west-1",      # Europe (Ireland)
      "eu-west-2",      # Europe (London)
      "eu-west-3",      # Europe (Paris)
      "eu-central-1",   # Europe (Frankfurt)
      "eu-north-1",     # Europe (Stockholm)
      "ap-northeast-1", # Asia Pacific (Tokyo)
      "ap-northeast-2", # Asia Pacific (Seoul)
      "ap-southeast-1", # Asia Pacific (Singapore)
      "ap-southeast-2", # Asia Pacific (Sydney)
      "ap-south-1"      # Asia Pacific (Mumbai)
    ], var.aws_region)
    error_message = "AWS region must be one of the supported regions for SageMaker Unified Studio. For more information, please see https://docs.aws.amazon.com/sagemaker-unified-studio/latest/adminguide/supported-regions.html"
  }
}

#####################################################################################
# Domain Configuration
#####################################################################################

variable "domain_name" {
  description = "Name of the SageMaker Unified Studio domain"
  type        = string
  default     = "terraform-quick-setup-domain"

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
  default     = "SageMaker Unified Studio domain with modular blueprint and profile setup"
}

#####################################################################################
# VPC and Network Configuration
#####################################################################################

variable "vpc_id" {
  description = "VPC ID for blueprint regional parameters. If null, the default VPC is used."
  type        = string
  default     = null

  validation {
    condition     = var.vpc_id == null || can(regex("^vpc-[a-z0-9]+$", var.vpc_id))
    error_message = "VPC ID must match pattern vpc-xxx."
  }
}

variable "subnet_ids" {
  description = "Subnet IDs for blueprint regional parameters. If null, subnets from the default VPC are used."
  type        = list(string)
  default     = null

  validation {
    condition     = var.subnet_ids == null || (length(var.subnet_ids) > 0 && alltrue([for s in var.subnet_ids : can(regex("^subnet-[a-z0-9]+$", s))]))
    error_message = "All subnet IDs must match pattern subnet-xxx and at least one is required."
  }
}

#####################################################################################
# S3 Bucket Configuration
#####################################################################################

variable "s3_bucket_name" {
  description = "Existing S3 bucket name for Tooling blueprint storage. If null, a dedicated bucket is created by the domain module."
  type        = string
  default     = null
}

#####################################################################################
# IAM Role Configuration
#####################################################################################

variable "user_role_policy_arns" {
  description = "List of IAM policy ARNs to apply as user role policies on the Tooling blueprint"
  type        = list(string)
  default     = null

  validation {
    condition     = var.user_role_policy_arns == null ? true : alltrue([for arn in var.user_role_policy_arns : can(regex("^arn:aws:iam::(aws|[0-9]{12}):policy/.+", arn))])
    error_message = "All entries must be valid IAM policy ARNs."
  }
}

variable "model_management_role_arn" {
  description = "ARN of existing AmazonDataZoneBedrockModelManagementRole. If null, auto-created by the domain module."
  type        = string
  default     = null

  validation {
    condition     = var.model_management_role_arn == null || can(regex("^arn:aws:iam::[0-9]{12}:role/.+", var.model_management_role_arn))
    error_message = "Must be a valid IAM role ARN."
  }
}

variable "model_consumption_role_arn" {
  description = "ARN of existing AmazonDataZoneBedrockFMConsumptionRole. If null, auto-created by the domain module."
  type        = string
  default     = null

  validation {
    condition     = var.model_consumption_role_arn == null || can(regex("^arn:aws:iam::[0-9]{12}:role/.+", var.model_consumption_role_arn))
    error_message = "Must be a valid IAM role ARN."
  }
}

#####################################################################################
# Blueprint Selection
#####################################################################################

variable "enable_generative_ai" {
  description = "Enable the Generative AI application development default project profile. Enabling this will create the project profile and enable the selected blueprints."
  type        = bool
  default     = true
}

variable "enable_sql_analytics" {
  description = "Enable the SQL analytics default project profile. Enabling this will create the project profile and enable the selected blueprints."
  type        = bool
  default     = true
}

variable "enable_all_capabilities" {
  description = "Enable the All capabilities default project profile. Enabling this will create the project profile and enable the selected blueprints."
  type        = bool
  default     = true
}

#####################################################################################
# Project Configuration
#####################################################################################

variable "project_name" {
  description = "Name of the project to create"
  type        = string
  default     = "terraform-quick-setup-project"

  validation {
    condition     = length(var.project_name) > 0 && length(var.project_name) <= 64
    error_message = "Project name must be between 1 and 64 characters."
  }
}

variable "project_description" {
  description = "Description of the project"
  type        = string
  default     = "Quick-setup project created with Terraform for SageMaker Unified Studio"
}

#####################################################################################
# SSO and User Configuration
#####################################################################################

variable "enable_sso" {
  description = "Enable single sign on (SSO) using the default IAM Identity Center instance for the region"
  type        = bool
  default     = false
}

variable "sso_users" {
  description = "A list of SSO user identifiers to add as members to the created domain and project"
  type        = list(string)
  default     = []
}

#####################################################################################
# Environment and Tagging
#####################################################################################

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
  default     = "terraform-quick-setup"
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
