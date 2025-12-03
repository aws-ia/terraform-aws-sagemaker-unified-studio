# SageMaker Unified Studio Domain Module
# This module creates a DataZone domain configured for SageMaker Unified Studio
# Equivalent to cloudformation/domain/create_domain.yaml

# Use awscc provider for SageMaker Unified Studio domain creation
resource "aws_datazone_domain" "main" {
  name                  = var.domain_name
  description           = var.description
  domain_execution_role = var.domain_execution_role_arn
  
  # Hardcoded to V2 for SageMaker Unified Studio (this project only supports SMUS)
  domain_version = "V2"
  
  # Service role is required for V2 domains (SageMaker Unified Studio)
  service_role = var.domain_execution_role_arn

  # Apply tags directly to the resource (aws provider expects map format)
  tags = merge(var.tags, {
    Provider = "aws"
    DomainVersion = "V2"
    Purpose = "SageMaker-Unified-Studio"
  })
}

# Data source to get current AWS account ID and region
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

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