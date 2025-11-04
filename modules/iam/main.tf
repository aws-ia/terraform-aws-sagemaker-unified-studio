# SageMaker Unified Studio IAM Roles Module
# This module creates IAM roles required for SageMaker Unified Studio domain
# Matches the IAM role parameters in cloudformation/domain/create_domain.yaml

# Get current AWS account and region information
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

# Attach AWS managed policy for DataZone domain execution
resource "aws_iam_role_policy_attachment" "domain_execution" {
  count = var.create_domain_execution_role ? 1 : 0
  
  role       = aws_iam_role.domain_execution[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDataZoneDomainExecutionRolePolicy"
}

# SageMaker Manage Access Role (matches CloudFormation AmazonSageMakerManageAccessRole parameter)
resource "aws_iam_role" "sagemaker_manage_access" {
  count = var.create_sagemaker_roles ? 1 : 0
  
  name        = var.sagemaker_manage_access_role_name != null ? var.sagemaker_manage_access_role_name : "${var.domain_name}-sagemaker-manage-access-role"
  description = "IAM role to manage access to SageMaker environments"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = [
            "datazone.amazonaws.com",
            "sagemaker.amazonaws.com"
          ]
        }
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = local.account_id
          }
        }
      }
    ]
  })
  
  tags = local.common_tags
}

# Attach policies for SageMaker manage access role
resource "aws_iam_role_policy_attachment" "sagemaker_manage_access" {
  count = var.create_sagemaker_roles ? 1 : 0
  
  role       = aws_iam_role.sagemaker_manage_access[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDataZoneSageMakerManageAccessRolePolicy"
}

# SageMaker Provisioning Role (matches CloudFormation AmazonSageMakerProvisioningRole parameter)
resource "aws_iam_role" "sagemaker_provisioning" {
  count = var.create_sagemaker_roles ? 1 : 0
  
  name        = var.sagemaker_provisioning_role_name != null ? var.sagemaker_provisioning_role_name : "${var.domain_name}-sagemaker-provisioning-role"
  description = "IAM role to provision SageMaker environments"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["sts:AssumeRole", "sts:SetContext"]
        Effect = "Allow"
        Principal = {
          Service = [
            "datazone.amazonaws.com",
            "sagemaker.amazonaws.com",
            "cloudformation.amazonaws.com",
            "sts.amazonaws.com"
          ]
        }
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = local.account_id
          }
        }
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
          "datazone:*",
          "ram:*",
          "sso:*",
          "kms:*",
          "codeconnections:ListConnections",
          "codeconnections:GetConnection",
          "codeconnections:ListTagsForResource",
          "codeconnections:TagResource",
          "codeconnections:UntagResource"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# SageMaker provisioning role inline policy as separate resource
resource "aws_iam_role_policy" "sagemaker_provisioning_inline" {
  count = var.create_sagemaker_roles ? 1 : 0
  
  name = "smus_provisioning_policy"
  role = aws_iam_role.sagemaker_provisioning[0].id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "cloudformation:CreateStack",
          "cloudformation:UpdateStack",
          "cloudformation:DeleteStack",
          "cloudformation:DescribeStacks",
          "cloudformation:DescribeStackEvents",
          "cloudformation:DescribeStackResources",
          "cloudformation:GetTemplate",
          "cloudformation:ValidateTemplate"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:cloudformation:${local.region}:${local.account_id}:stack/sagemaker-*/*",
          "arn:aws:cloudformation:${local.region}:${local.account_id}:stack/${var.domain_name}-*/*"
        ]
      },
      {
        Action = [
          "sagemaker:CreateNotebookInstance",
          "sagemaker:UpdateNotebookInstance",
          "sagemaker:DeleteNotebookInstance",
          "sagemaker:DescribeNotebookInstance",
          "sagemaker:StartNotebookInstance",
          "sagemaker:StopNotebookInstance",
          "sagemaker:CreateEndpoint",
          "sagemaker:UpdateEndpoint",
          "sagemaker:DeleteEndpoint",
          "sagemaker:DescribeEndpoint",
          "sagemaker:CreateModel",
          "sagemaker:DeleteModel",
          "sagemaker:DescribeModel"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:sagemaker:${local.region}:${local.account_id}:notebook-instance/*",
          "arn:aws:sagemaker:${local.region}:${local.account_id}:endpoint/*",
          "arn:aws:sagemaker:${local.region}:${local.account_id}:model/*"
        ]
      },
      {
        Action = [
          "ec2:CreateSecurityGroup",
          "ec2:DeleteSecurityGroup",
          "ec2:DescribeSecurityGroups",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:RunInstances",
          "ec2:TerminateInstances",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeImages",
          "ec2:DescribeKeyPairs",
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "s3:CreateBucket",
          "s3:DeleteBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::sagemaker-*",
          "arn:aws:s3:::sagemaker-*/*",
          "arn:aws:s3:::${var.domain_name}-*",
          "arn:aws:s3:::${var.domain_name}-*/*"
        ]
      },
      {
        Action = [
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:GetRole",
          "iam:PassRole",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:GetRolePolicy",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies",
          "iam:TagRole",
          "iam:UntagRole",
          "iam:CreateInstanceProfile",
          "iam:DeleteInstanceProfile",
          "iam:GetInstanceProfile",
          "iam:AddRoleToInstanceProfile",
          "iam:RemoveRoleFromInstanceProfile"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:iam::${local.account_id}:role/sagemaker-*",
          "arn:aws:iam::${local.account_id}:role/${var.domain_name}-*",
          "arn:aws:iam::${local.account_id}:role/SageMakerStudio*",
          "arn:aws:iam::${local.account_id}:role/AmazonSageMaker*",
          "arn:aws:iam::${local.account_id}:role/sm-provisioning/datazone_usr*",
          "arn:aws:iam::${local.account_id}:instance-profile/sagemaker-*",
          "arn:aws:iam::${local.account_id}:instance-profile/SageMakerStudio*"
        ]
      },
      {
        Action = [
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:GetRole",
          "iam:PassRole",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:GetRolePolicy",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies",
          "iam:TagRole",
          "iam:UntagRole"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:iam::${local.account_id}:role/SageMakerStudioQueryExecutionRole*",
          "arn:aws:iam::${local.account_id}:role/SageMakerStudioExecutionRole*",
          "arn:aws:iam::${local.account_id}:role/SageMakerStudioUserRole*"
        ]
      },
      {
        Action = [
          "lakeformation:GetDataLakeSettings",
          "lakeformation:PutDataLakeSettings",
          "lakeformation:DescribeResource",
          "lakeformation:ListResources",
          "lakeformation:GrantPermissions",
          "lakeformation:RevokePermissions",
          "lakeformation:ListPermissions",
          "lakeformation:BatchGrantPermissions",
          "lakeformation:BatchRevokePermissions"
        ]
        Effect = "Allow"
        Resource = "*"
      }
    ]
  })
}

# SageMaker manage access role inline policy as separate resource
resource "aws_iam_role_policy" "sagemaker_manage_access_inline" {
  count = var.create_sagemaker_roles ? 1 : 0
  
  name = "smus_manage_access_policy"
  role = aws_iam_role.sagemaker_manage_access[0].id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sagemaker:CreateDomain",
          "sagemaker:UpdateDomain",
          "sagemaker:DeleteDomain",
          "sagemaker:DescribeDomain",
          "sagemaker:ListDomains",
          "sagemaker:CreateUserProfile",
          "sagemaker:UpdateUserProfile",
          "sagemaker:DeleteUserProfile",
          "sagemaker:DescribeUserProfile",
          "sagemaker:ListUserProfiles",
          "sagemaker:CreateApp",
          "sagemaker:DeleteApp",
          "sagemaker:DescribeApp",
          "sagemaker:ListApps"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:sagemaker:${local.region}:${local.account_id}:domain/*",
          "arn:aws:sagemaker:${local.region}:${local.account_id}:user-profile/*",
          "arn:aws:sagemaker:${local.region}:${local.account_id}:app/*"
        ]
      },
      {
        Action = [
          "sagemaker:CreateProject",
          "sagemaker:UpdateProject",
          "sagemaker:DeleteProject",
          "sagemaker:DescribeProject",
          "sagemaker:ListProjects"
        ]
        Effect = "Allow"
        Resource = "arn:aws:sagemaker:${local.region}:${local.account_id}:project/*"
      },
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::sagemaker-*",
          "arn:aws:s3:::sagemaker-*/*",
          "arn:aws:s3:::${var.domain_name}-*",
          "arn:aws:s3:::${var.domain_name}-*/*"
        ]
      },
      {
        Action = "iam:PassRole"
        Effect = "Allow"
        Resource = [
          "arn:aws:iam::${local.account_id}:role/sagemaker-*",
          "arn:aws:iam::${local.account_id}:role/${var.domain_name}-*"
        ]
        Condition = {
          StringEquals = {
            "iam:PassedToService" = "sagemaker.amazonaws.com"
          }
        }
      }
    ]
  })
}

# Attach policies for SageMaker provisioning role
resource "aws_iam_role_policy_attachment" "sagemaker_provisioning" {
  count = var.create_sagemaker_roles ? 1 : 0
  
  role       = aws_iam_role.sagemaker_provisioning[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/SageMakerStudioProjectProvisioningRolePolicy"
}
