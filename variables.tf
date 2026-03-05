# Domain Module Variables
# These variables match the parameters in cloudformation/domain/create_domain.yaml

variable "domain_name" {
  description = "Name of the DataZone domain (matches CloudFormation DomainName parameter)"
  type        = string
  default     = null
  
  validation {
    condition     = var.domain_name == null || can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]$", var.domain_name))
    error_message = "Domain name must contain only alphanumeric characters and hyphens, and cannot start or end with a hyphen."
  }
  
  validation {
    condition     = var.domain_name == null || (length(var.domain_name) >= 1 && length(var.domain_name) <= 64)
    error_message = "Domain name must be between 1 and 64 characters long."
  }
}

variable "description" {
  description = "Description of the domain"
  type        = string
  default     = "SageMaker Unified Studio domain managed by Terraform"
}

# Domain Execution Role Configuration
variable "domain_execution_role_arn" {
  description = "ARN of the domain execution role for SageMaker Unified Studio"
  type        = string
  default     = null
  
  validation {
    condition = var.domain_execution_role_arn == null || can(regex("^arn:aws:iam::[0-9]{12}:role/.+", var.domain_execution_role_arn))
    error_message = "Domain execution role ARN must be a valid IAM role ARN."
  }
}

# Domain Service Role Configuration
variable "domain_service_role_arn" {
  description = "ARN of the domain service role for SageMaker Unified Studio"
  type        = string
  default     = null

  validation {
    condition = var.domain_service_role_arn == null || can(regex("^arn:aws:iam::[0-9]{12}:role/.+", var.domain_service_role_arn))
    error_message = "Domain service role ARN must be a valid IAM role ARN."
  }
}

variable "tags" {
  description = "Tags to apply to the domain and related resources"
  type        = map(string)
  default     = {}
  
  validation {
    condition     = length(var.tags) <= 50
    error_message = "Maximum of 50 tags allowed."
  }
}

variable "enable_sso" {
  description = "Choose to enable single sign on (SSO) and use an existing AWS IAM Identity Center Instance. When set to true, this will use the default IAM IDC instance that is enabled for the account within the same region as the domain."
  type = bool
  default = false
}

variable "kms_key_identifier" {
  description = "ARN of the KMS key used to encrypt the Amazon DataZone domain, metadata and reporting data (if null, uses AWS managed key)"
  type        = string
  default     = null
}

# --- Blueprint Role Configuration ---
variable "manage_access_role_arn" {
  description = "ARN of existing AmazonSageMakerManageAccess role. If not provided, the role is auto-created."
  type        = string
  default     = null

  validation {
    condition     = var.manage_access_role_arn == null || can(regex("^arn:aws:iam::[0-9]{12}:role/.+", var.manage_access_role_arn))
    error_message = "Manage access role ARN must be a valid IAM role ARN."
  }
}

variable "provisioning_role_arn" {
  description = "ARN of existing AmazonSageMakerProvisioning role. If not provided, the role is auto-created."
  type        = string
  default     = null

  validation {
    condition     = var.provisioning_role_arn == null || can(regex("^arn:aws:iam::[0-9]{12}:role/.+", var.provisioning_role_arn))
    error_message = "Provisioning role ARN must be a valid IAM role ARN."
  }
}

# --- Tooling Blueprint Configuration ---
variable "vpc_id" {
  description = "VPC ID for Tooling blueprint regional parameters"
  type        = string

  validation {
    condition     = can(regex("^vpc-[a-z0-9]+$", var.vpc_id))
    error_message = "VPC ID must match pattern vpc-xxx."
  }
}

variable "subnet_ids" {
  description = "Subnet IDs for Tooling blueprint regional parameters"
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) > 0
    error_message = "At least one subnet ID required."
  }

  validation {
    condition     = alltrue([for s in var.subnet_ids : can(regex("^subnet-[a-z0-9]+$", s))])
    error_message = "All subnet IDs must match pattern subnet-xxx."
  }
}

variable "s3_bucket_name" {
  description = "Existing S3 bucket name for Tooling blueprint storage. If null, a dedicated bucket is created."
  type        = string
  default     = null

  validation {
    condition     = var.s3_bucket_name == null || can(regex("^[a-z0-9][a-z0-9.-]*[a-z0-9]$", var.s3_bucket_name))
    error_message = "S3 bucket name must be valid."
  }
}

# --- User Role Policy Configuration (R8) ---
variable "user_role_policy_arns" {
  description = "List of IAM policy ARNs to apply as user role policies on the Tooling blueprint. Defaults to SageMakerStudioProjectUserRolePolicy if not provided."
  type        = list(string)
  default     = null

  validation {
    condition     = var.user_role_policy_arns == null || alltrue([for arn in var.user_role_policy_arns : can(regex("^arn:aws:iam::(aws|[0-9]{12}):policy/.+", arn))])
    error_message = "All entries must be valid IAM policy ARNs."
  }
}

# --- Query Execution Role Configuration (R3 AC6) ---
variable "query_execution_role_arn" {
  description = "ARN of a custom query execution role for the Tooling blueprint. If not provided, the service uses the default AmazonSageMakerQueryExecution role."
  type        = string
  default     = null

  validation {
    condition     = var.query_execution_role_arn == null || can(regex("^arn:aws:iam::[0-9]{12}:role/.+", var.query_execution_role_arn))
    error_message = "Must be a valid IAM role ARN."
  }
}
