# Variables for SageMaker Unified Studio Cross-Account Example.
#
# Variables that aren't currently consumed by main.tf are commented out below.
# Uncomment them when wiring up additional functionality (project profiles,
# project creation, membership management, etc.).

#####################################################################################
# AWS Configuration
#####################################################################################

variable "source_profile" {
  description = "AWS named profile (from ~/.aws/credentials or ~/.aws/config) for the source account that owns the SageMaker Unified Studio domain. Set to null to use the default credential chain."
  type        = string
  default     = null
}

variable "destination_profile" {
  description = "AWS named profile for the destination account (the account being associated with the domain via cross-account RAM share). Set to null to use the default credential chain."
  type        = string
  default     = null
}

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

variable "using_organizations" {
  description = "Set to true if both accounts are in the same AWS Organization. When true, RAM shares are auto-accepted and the manual accept step is skipped."
  type        = bool
  default     = false
}

# # aws_region kept for backwards compatibility with downstream resources.
# # Unused in this example; uncomment if needed.
# variable "aws_region" {
#   description = "Deprecated. Alias for source_region."
#   type        = string
#   default     = "us-east-1"
# }

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
  default     = "SageMaker Unified Studio domain shared cross-account"
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

# # ARN of existing AmazonDataZoneBedrockModelManagementRole. Unused; the domain
# # module auto-creates this when not provided. Uncomment to reference an
# # existing role.
# variable "model_management_role_arn" {
#   description = "ARN of existing AmazonDataZoneBedrockModelManagementRole."
#   type        = string
#   default     = null
# }

# # ARN of existing AmazonDataZoneBedrockFMConsumptionRole. Unused; see above.
# variable "model_consumption_role_arn" {
#   description = "ARN of existing AmazonDataZoneBedrockFMConsumptionRole."
#   type        = string
#   default     = null
# }

#####################################################################################
# Project Profile Selection (unused — this example does not create profiles)
#####################################################################################

# variable "enable_generative_ai" {
#   description = "Enable the Generative AI application development default project profile."
#   type        = bool
#   default     = true
# }

# variable "enable_sql_analytics" {
#   description = "Enable the SQL analytics default project profile."
#   type        = bool
#   default     = true
# }

# variable "enable_all_capabilities" {
#   description = "Enable the All capabilities default project profile."
#   type        = bool
#   default     = true
# }

#####################################################################################
# Project Configuration (unused — this example does not create a project)
#####################################################################################

# variable "project_name" {
#   description = "Name of the project to create"
#   type        = string
#   default     = "terraform-quick-setup-project"
# }

# variable "project_description" {
#   description = "Description of the project"
#   type        = string
#   default     = "Cross-account project"
# }

#####################################################################################
# SSO and User Configuration
#####################################################################################

variable "enable_sso" {
  description = "Enable single sign on (SSO) using the default IAM Identity Center instance for the region"
  type        = bool
  default     = false
}

# # Unused — no membership wiring in this example. Uncomment when adding
# # membership modules.
# variable "sso_users" {
#   description = "A list of SSO user identifiers to add as members"
#   type        = list(string)
#   default     = []
# }

#####################################################################################
# Environment and Tagging
#####################################################################################

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod). Used in default_tags on both AWS providers."
  type        = string
  default     = "test"

  validation {
    condition     = contains(["dev", "staging", "prod", "test"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod, test."
  }
}

# # Owner tag — unused. Uncomment to add an Owner tag via merge into default_tags.
# variable "owner" {
#   description = "Owner of the domain (for tagging purposes)"
#   type        = string
#   default     = "terraform-quick-setup"
# }

# # Custom tags map — unused. Uncomment to merge into provider default_tags.
# variable "tags" {
#   description = "Additional tags to apply to all resources"
#   type        = map(string)
#   default     = {}
# }
