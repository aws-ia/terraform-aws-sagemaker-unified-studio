#####################################################################################
# SageMaker Unified Studio Domain Module
# This module creates a DataZone domain configured for SageMaker Unified Studio
# Equivalent to cloudformation/domain/create_domain.yaml
#####################################################################################

######################################
# Defaults and Locals
######################################
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id

  # Generate dynamic domain name if not provided
  domain_name = var.domain_name != null ? var.domain_name : "domain-${formatdate("MM-DD-YYYY-HHmmss", timestamp())}"

  # Default role names for SageMaker Unified Studio
  default_domain_execution_role_name = "AmazonSageMakerDomainExecution"
  default_domain_service_role_name   = "AmazonSageMakerDomainService"

  # Check if existing roles were found by checking if list is non-empty
  domain_execution_role_exists = var.domain_execution_role_arn != null ? true : length(data.aws_iam_roles.domain_execution_role.arns) > 0
  domain_service_role_exists   = var.domain_service_role_arn != null ? true : length(data.aws_iam_roles.domain_service_role.arns) > 0

  # Determine final role ARNs: user-provided > existing > newly created
  domain_execution_role_arn = var.domain_execution_role_arn != null ? var.domain_execution_role_arn : (
    local.domain_execution_role_exists ? tolist(data.aws_iam_roles.domain_execution_role.arns)[0] : aws_iam_role.domain_execution[0].arn
  )

  domain_service_role_arn = var.domain_service_role_arn != null ? var.domain_service_role_arn : (
    local.domain_service_role_exists ? tolist(data.aws_iam_roles.domain_service_role.arns)[0] : aws_iam_role.domain_service[0].arn
  )
}

#####################################################################################
# IAM Role Existence Check and Creation (R4)
#####################################################################################

data "aws_iam_roles" "domain_execution_role" {
  name_regex = "^${local.default_domain_execution_role_name}$"
}

data "aws_iam_roles" "domain_service_role" {
  name_regex = "^${local.default_domain_service_role_name}$"
}

# Create AmazonSageMakerDomainExecution role if it doesn't exist
resource "aws_iam_role" "domain_execution" {
  count = !local.domain_execution_role_exists ? 1 : 0

  name = local.default_domain_execution_role_name
  path = "/service-role/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "datazone.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:SetContext"
        ]
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = local.account_id
          }
        }
      }
    ]
  })

  tags = merge(var.tags, {
    ManagedBy = "Terraform"
    Purpose   = "SageMaker-Unified-Studio-Domain-Execution"
  })
}

# Attach the managed policy to domain execution role
resource "aws_iam_role_policy_attachment" "domain_execution_policy" {
  count      = !local.domain_execution_role_exists ? 1 : 0
  role       = aws_iam_role.domain_execution[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/SageMakerStudioDomainExecutionRolePolicy"
}

# Create AmazonSageMakerDomainService role if it doesn't exist
resource "aws_iam_role" "domain_service" {
  count = !local.domain_service_role_exists ? 1 : 0

  name = local.default_domain_service_role_name
  path = "/service-role/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "datazone.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:SetContext"
        ]
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = local.account_id
          }
        }
      }
    ]
  })

  tags = merge(var.tags, {
    ManagedBy = "Terraform"
    Purpose   = "SageMaker-Unified-Studio-Domain-Service"
  })
}

# Attach the managed policy to domain service role
resource "aws_iam_role_policy_attachment" "domain_service_policy" {
  count      = !local.domain_service_role_exists ? 1 : 0
  role       = aws_iam_role.domain_service[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/SageMakerStudioDomainServiceRolePolicy"
}

#####################################################################################
# Domain creation
#####################################################################################

# Use awscc provider for SageMaker Unified Studio domain creation
resource "aws_datazone_domain" "main" {
  name                  = local.domain_name
  description           = var.description
  domain_execution_role = local.domain_execution_role_arn
  # Optionally enable SSO on the instance and use the default IDC instance for the region
  single_sign_on {
    type            = (var.enable_sso) ? "IAM_IDC" : "DISABLED"
    user_assignment = (var.enable_sso) ? "AUTOMATIC" : null
  }

  # Hardcoded to V2 for SageMaker Unified Studio (this project only supports SMUS)
  domain_version = "V2"

  # Service role is required for V2 domains (SageMaker Unified Studio)
  service_role = local.domain_service_role_arn

  # KMS encryption configuration (optional)
  kms_key_identifier = var.kms_key_identifier

  # Apply tags directly to the resource (aws provider expects map format)
  tags = merge(var.tags, {
    Provider      = "aws"
    DomainVersion = "V2"
    Purpose       = "SageMaker-Unified-Studio"
  })
}

# Data source needed to get root domain unit
data "awscc_datazone_domain" "main" {
  id = aws_datazone_domain.main.id
}

# Deploy hidden project and project profile used to govern/enable bedrock models
resource "awscc_datazone_project_profile" "model_governance_project_profile" {
  name                   = "Generative AI model governance"
  description            = "Govern generative AI models powered by Amazon Bedrock"
  status                 = "ENABLED"
  domain_identifier      = aws_datazone_domain.main.id
  domain_unit_identifier = data.awscc_datazone_domain.main.root_domain_unit_id
}

resource "awscc_datazone_project" "model_governance_project" {
  domain_identifier  = aws_datazone_domain.main.id
  name               = "GenerativeAIModelGovernanceProject"
  project_profile_id = awscc_datazone_project_profile.model_governance_project_profile.project_profile_id
}