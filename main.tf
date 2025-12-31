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
  region     = data.aws_region.current.id
  
  # Generate dynamic domain name if not provided
  domain_name = var.domain_name != null ? var.domain_name : "domain-${formatdate("MM-DD-YYYY-HHMMSS", timestamp())}"
  
  # Default to AWS managed service role for SageMaker Unified Studio
  domain_execution_role_arn = var.domain_execution_role_arn != null ? var.domain_execution_role_arn : "arn:aws:iam::${local.account_id}:role/service-role/AmazonSageMakerDomainExecution"
  domain_service_role_arn   = var.domain_service_role_arn != null ? var.domain_service_role_arn : "arn:aws:iam::${local.account_id}:role/service-role/AmazonSageMakerDomainService"
  
  # Common tags for all resources
  common_tags = merge(var.tags, {
    ManagedBy = "Terraform"
    Module    = "sagemaker-unified-studio"
  })
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
    Provider = "aws"
    DomainVersion = "V2"
    Purpose = "SageMaker-Unified-Studio"
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
  domain_identifier       = aws_datazone_domain.main.id
  name                    = "GenerativeAIModelGovernanceProject"
  project_profile_id      = awscc_datazone_project_profile.model_governance_project_profile.project_profile_id
}