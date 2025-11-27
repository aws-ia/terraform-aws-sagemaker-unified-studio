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
  
  # Common tags for all IAM resources
  common_tags = merge(var.tags, {
    ManagedBy = "Terraform"
    Module    = "sagemaker-unified-studio-iam"
  })
}

#####################################################################################
# IAM roles and policies for SageMaker Unified Studio Domain
#####################################################################################

# Domain Execution Role (matches CloudFormation DomainExecutionRole parameter)
resource "aws_iam_role" "domain_execution" {
  count = var.create_domain_execution_role ? 1 : 0
  
  name        = var.domain_execution_role_name != null ? var.domain_execution_role_name : "${var.domain_name}-domain-execution-role"
  description = "IAM role for SageMaker Unified Studio domain execution"
  
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "datazone.amazonaws.com"
            },
            "Action": [
                "sts:AssumeRole",
                "sts:TagSession"
            ],
            "Condition": {
                "StringEquals": {
                    "aws:SourceAccount": local.account_id
                },
                "ForAllValues:StringLike": {
                    "aws:TagKeys": [
                        "datazone*"
                    ]
                }
            }
        },
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "sagemaker.amazonaws.com"
            },
            "Action": [
                "sts:AssumeRole",
                "sts:TagSession"
            ],
            "Condition": {
                "StringEquals": {
                    "aws:SourceAccount": local.account_id
                }
            }
        },
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudformation.amazonaws.com"
            },
            "Action": [
                "sts:AssumeRole",
                "sts:TagSession"
            ]
        }
    ]
  })
  
  tags = local.common_tags
}

# Domain execution role inline policy as separate resource
resource "aws_iam_role_policy" "domain_execution_inline" {
  count = var.create_domain_execution_role ? 1 : 0
  
  name = "domain_execution_policy"
  role = aws_iam_role.domain_execution[0].id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "datazone:CreateDomain",
          "datazone:UpdateDomain",
          "datazone:DeleteDomain",
          "datazone:GetDomain",
          "datazone:ListDomains",
          "datazone:CreateProject",
          "datazone:UpdateProject",
          "datazone:DeleteProject",
          "datazone:GetProject",
          "datazone:ListProjects",
          "datazone:CreateEnvironment",
          "datazone:UpdateEnvironment",
          "datazone:DeleteEnvironment",
          "datazone:GetEnvironment",
          "datazone:ListEnvironments"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:datazone:${local.region}:${local.account_id}:domain/*",
          "arn:aws:datazone:${local.region}:${local.account_id}:project/*",
          "arn:aws:datazone:${local.region}:${local.account_id}:environment/*"
        ]
      },
      {
        Action = [
          "ram:CreateResourceShare",
          "ram:UpdateResourceShare",
          "ram:DeleteResourceShare",
          "ram:GetResourceShares",
          "ram:AssociateResourceShare",
          "ram:DisassociateResourceShare",
          "ram:AcceptResourceShareInvitation",
          "ram:RejectResourceShareInvitation"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:ram:${local.region}:${local.account_id}:resource-share/*",
          "arn:aws:ram:${local.region}:${local.account_id}:invitation/*"
        ]
      },
      {
        Action = [
          "sso:CreateApplication",
          "sso:UpdateApplication",
          "sso:DeleteApplication",
          "sso:DescribeApplication",
          "sso:ListApplications",
          "sso:CreatePermissionSet",
          "sso:UpdatePermissionSet",
          "sso:DeletePermissionSet",
          "sso:DescribePermissionSet",
          "sso:ListPermissionSets"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:sso:::instance/*",
          "arn:aws:sso:::account/*",
          "arn:aws:sso:::permission-set/*"
        ]
      },
      {
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:Encrypt",
          "kms:GenerateDataKey",
          "kms:ReEncrypt*"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:kms:${local.region}:${local.account_id}:key/*"
        ]
        Condition = {
          StringEquals = {
            "kms:ViaService" = [
              "datazone.${local.region}.amazonaws.com",
              "sagemaker.${local.region}.amazonaws.com"
            ]
          }
        }
      },
      {
        Action = [
          "codeconnections:ListConnections",
          "codeconnections:GetConnection",
          "codeconnections:ListTagsForResource",
          "codeconnections:TagResource",
          "codeconnections:UntagResource"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:codeconnections:${local.region}:${local.account_id}:connection/*"
        ]
      }
    ]
  })
}

# Attach AWS managed policy for DataZone domain execution
resource "aws_iam_role_policy_attachment" "domain_execution" {
  count = var.create_domain_execution_role ? 1 : 0
  
  role       = aws_iam_role.domain_execution[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDataZoneDomainExecutionRolePolicy"
}

#####################################################################################
# Domain creation
#####################################################################################

# Use awscc provider for SageMaker Unified Studio domain creation
resource "aws_datazone_domain" "main" {
  name                  = var.domain_name
  description           = var.description
  domain_execution_role = var.create_domain_execution_role ? aws_iam_role.domain_execution[0].arn : var.domain_execution_role_arn
  
  # Hardcoded to V2 for SageMaker Unified Studio (this project only supports SMUS)
  domain_version = "V2"
  
  # Service role is required for V2 domains (SageMaker Unified Studio)
  service_role = var.create_domain_execution_role ? aws_iam_role.domain_execution[0].arn : var.domain_execution_role_arn

  # Apply tags directly to the resource (aws provider expects map format)
  tags = merge(var.tags, {
    Provider = "aws"
    DomainVersion = "V2"
    Purpose = "SageMaker-Unified-Studio"
  })
}
