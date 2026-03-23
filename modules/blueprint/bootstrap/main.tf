#####################################################################################
# Singular Blueprint Configuration Module
# Creates exactly one blueprint configuration per invocation.
# Invoke this module multiple times with different blueprint_name values.
#####################################################################################

######################################
# Data Sources
######################################

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
#####################

locals {
  account_id        = data.aws_caller_identity.current.account_id
  region            = data.aws_region.current.id
  domain_id_suffix  = replace(var.domain_id, "/^dzd-/", "")
  domain_account_id = var.domain_account_id != null ? var.domain_account_id : local.account_id

  # 3-tier role resolution: user-provided > existing > auto-create
  default_provisioning_role_name = "AmazonSageMakerProvisioning-${local.account_id}-${var.domain_id}"

  default_manage_access_role_name = "AmazonSageMakerManageAccess-${local.region}-${var.domain_id}"
  common_tags = merge(var.tags, {
    ManagedBy = "Terraform"
    Module    = "sagemaker-unified-studio-blueprint"
  })
}

# Create AmazonSageMakerProvisioning role if it doesn't exist
resource "aws_iam_role" "sagemaker_provisioning" {
  count = var.create_provisioning_role ? 1 : 0

  name = local.default_provisioning_role_name
  path = "/service-role/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "datazone.amazonaws.com"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = local.domain_account_id
          }
        }
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "sagemaker_provisioning" {
  count      = var.create_provisioning_role ? 1 : 0
  role       = aws_iam_role.sagemaker_provisioning[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/SageMakerStudioProjectProvisioningRolePolicy"
}

# Create ManageAccess role if it doesn't exist
resource "aws_iam_role" "sagemaker_manage_access" {
  count = var.create_manage_access_role ? 1 : 0

  name        = local.default_manage_access_role_name
  description = "This role grants Amazon SageMaker Unified Studio permissions to publish, grant access, and revoke access to Amazon SageMaker Lakehouse, AWS Glue Data Catalog and Amazon Redshift data."

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "datazone.amazonaws.com"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = local.domain_account_id
          }
          ArnEquals = {
            "aws:SourceArn" = "arn:aws:datazone:${local.region}:${local.domain_account_id}:domain/${var.domain_id}"
          }
        }
      }
    ]
  })

  tags = local.common_tags
}

# Custom Redshift secret access policy
resource "aws_iam_policy" "sagemaker_manage_access_redshift" { #tfsec:ignore:aws-iam-no-policy-wildcards -- Resource '*' is scoped by a StringEquals condition on secretsmanager:ResourceTag/AmazonDataZoneDomain, limiting access to secrets tagged with the specific domain ID
  count = var.create_manage_access_role ? 1 : 0

  name = "AmazonSageMakerManageAccessPolicy-${local.domain_id_suffix}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "RedshiftSecretStatement"
        Effect   = "Allow"
        Action   = "secretsmanager:GetSecretValue"
        Resource = "*"
        Condition = {
          StringEquals = {
            "secretsmanager:ResourceTag/AmazonDataZoneDomain" = var.domain_id
          }
        }
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "sagemaker_manage_access_custom" {
  count      = var.create_manage_access_role ? 1 : 0
  role       = aws_iam_role.sagemaker_manage_access[0].name
  policy_arn = aws_iam_policy.sagemaker_manage_access_redshift[0].arn
}

resource "aws_iam_role_policy_attachment" "sagemaker_manage_access" {
  count      = var.create_manage_access_role ? 1 : 0
  role       = aws_iam_role.sagemaker_manage_access[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDataZoneSageMakerManageAccessRolePolicy"
}

resource "aws_iam_role_policy_attachment" "glue_manage_access" {
  count      = var.create_manage_access_role ? 1 : 0
  role       = aws_iam_role.sagemaker_manage_access[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDataZoneGlueManageAccessRolePolicy"
}

resource "aws_iam_role_policy_attachment" "redshift_manage_access" {
  count      = var.create_manage_access_role ? 1 : 0
  role       = aws_iam_role.sagemaker_manage_access[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDataZoneRedshiftManageAccessRolePolicy"
}

######################################
# Lake Formation Configuration (from R4)
######################################

resource "aws_lakeformation_data_lake_settings" "main" {
  count = var.configure_lake_formation ? 1 : 0

  admins = toset(concat([for role in aws_iam_role.sagemaker_provisioning : role.arn], [for role in aws_iam_role.sagemaker_manage_access : role.arn]))

  depends_on = [
    aws_iam_role.sagemaker_provisioning,
    aws_iam_role.sagemaker_manage_access
  ]
}
