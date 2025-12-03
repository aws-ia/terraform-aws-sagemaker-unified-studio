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

# Data source to get the root domain unit ID
data "awscc_datazone_domain" "main" {
  id = aws_datazone_domain.main.id
}

