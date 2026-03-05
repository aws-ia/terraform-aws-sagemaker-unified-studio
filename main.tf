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
  domain_name = var.domain_name != null ? var.domain_name : "domain-${formatdate("MM-DD-YYYY-HHmmss", timestamp())}"

  # Default role names for SageMaker Unified Studio
  default_domain_execution_role_name = "AmazonSageMakerDomainExecution"
  default_domain_service_role_name   = "AmazonSageMakerDomainService"
  default_provisioning_role_name     = "AmazonSageMakerProvisioning-${local.account_id}"

  # Check if existing roles were found by checking if list is non-empty
  domain_execution_role_exists = var.domain_execution_role_arn != null ? true : length(data.aws_iam_roles.domain_execution_role.arns) > 0
  domain_service_role_exists   = var.domain_service_role_arn != null ? true : length(data.aws_iam_roles.domain_service_role.arns) > 0
  provisioning_role_exists     = var.provisioning_role_arn != null ? true : length(data.aws_iam_roles.provisioning_role.arns) > 0

  # Determine final role ARNs: user-provided > existing > newly created
  domain_execution_role_arn = var.domain_execution_role_arn != null ? var.domain_execution_role_arn : (
    local.domain_execution_role_exists ? tolist(data.aws_iam_roles.domain_execution_role.arns)[0] : aws_iam_role.domain_execution[0].arn
  )

  domain_service_role_arn = var.domain_service_role_arn != null ? var.domain_service_role_arn : (
    local.domain_service_role_exists ? tolist(data.aws_iam_roles.domain_service_role.arns)[0] : aws_iam_role.domain_service[0].arn
  )

  provisioning_role_arn = var.provisioning_role_arn != null ? var.provisioning_role_arn : (
    local.provisioning_role_exists ? tolist(data.aws_iam_roles.provisioning_role.arns)[0] : aws_iam_role.sagemaker_provisioning[0].arn
  )

  # Manage access role name is domain-scoped (includes region and domain ID)
  # Computed after domain creation — see locals block below
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

data "aws_iam_roles" "provisioning_role" {
  name_regex = "^${local.default_provisioning_role_name}$"
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
# Blueprint IAM Roles — Provisioning and Manage Access (R3)
# Created here so the Tooling blueprint (part of domain) can use them.
# Outputs are available for other blueprint modules to consume.
#####################################################################################

# Create AmazonSageMakerProvisioning role if it doesn't exist
resource "aws_iam_role" "sagemaker_provisioning" {
  count = !local.provisioning_role_exists ? 1 : 0

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
            "aws:SourceAccount" = local.account_id
          }
        }
      }
    ]
  })

  tags = merge(var.tags, {
    ManagedBy = "Terraform"
    Purpose   = "SageMaker-Unified-Studio-Provisioning"
  })
}

resource "aws_iam_role_policy_attachment" "sagemaker_provisioning" {
  count      = !local.provisioning_role_exists ? 1 : 0
  role       = aws_iam_role.sagemaker_provisioning[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/SageMakerStudioProjectProvisioningRolePolicy"
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

#####################################################################################
# Manage Access Role (domain-scoped, created after domain)
#####################################################################################

locals {
  default_manage_access_role_name = "AmazonSageMakerManageAccess-${local.region}-${aws_datazone_domain.main.id}"
  manage_access_role_exists       = var.manage_access_role_arn != null
  manage_access_role_arn = var.manage_access_role_arn != null ? var.manage_access_role_arn : aws_iam_role.sagemaker_manage_access[0].arn
}

resource "aws_iam_role" "sagemaker_manage_access" {
  count = !local.manage_access_role_exists ? 1 : 0

  name        = local.default_manage_access_role_name
  description = "Grants Amazon SageMaker Unified Studio permissions to manage access to data resources."

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
            "aws:SourceAccount" = local.account_id
          }
          ArnEquals = {
            "aws:SourceArn" = "arn:aws:datazone:${local.region}:${local.account_id}:domain/${data.awscc_datazone_domain.main.root_domain_unit_id}"
          }
        }
      }
    ]
  })

  tags = merge(var.tags, {
    ManagedBy = "Terraform"
    Purpose   = "SageMaker-Unified-Studio-ManageAccess"
  })
}

resource "aws_iam_role_policy_attachment" "manage_access_sagemaker" {
  count      = !local.manage_access_role_exists ? 1 : 0
  role       = aws_iam_role.sagemaker_manage_access[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDataZoneSageMakerManageAccessRolePolicy"
}

resource "aws_iam_role_policy_attachment" "manage_access_glue" {
  count      = !local.manage_access_role_exists ? 1 : 0
  role       = aws_iam_role.sagemaker_manage_access[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDataZoneGlueManageAccessRolePolicy"
}

resource "aws_iam_role_policy_attachment" "manage_access_redshift" {
  count      = !local.manage_access_role_exists ? 1 : 0
  role       = aws_iam_role.sagemaker_manage_access[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDataZoneRedshiftManageAccessRolePolicy"
}

# Customer managed policy for Redshift secret access
# Resource = "*" is scoped by condition tag (AmazonDataZoneDomain) — matches console-created policy
#tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_policy" "manage_access_redshift_secret" {
  count = !local.manage_access_role_exists ? 1 : 0

  name = "AmazonSageMakerManageAccessPolicy-${replace(aws_datazone_domain.main.id, "/^dzd-/", "")}"
  path = "/service-role/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "RedshiftSecretStatement"
        Effect = "Allow"
        Action = "secretsmanager:GetSecretValue"
        Resource = "*"
        Condition = {
          StringEquals = {
            "secretsmanager:ResourceTag/AmazonDataZoneDomain" = aws_datazone_domain.main.id
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "manage_access_redshift_secret" {
  count      = !local.manage_access_role_exists ? 1 : 0
  role       = aws_iam_role.sagemaker_manage_access[0].name
  policy_arn = aws_iam_policy.manage_access_redshift_secret[0].arn
}

#####################################################################################
# Tooling Blueprint Configuration (R3 + R8)
# Uses awscc provider for global_parameters support (user role policy)
#####################################################################################

data "aws_datazone_environment_blueprint" "tooling" {
  domain_id = aws_datazone_domain.main.id
  name      = "Tooling"
  managed   = true

  depends_on = [aws_datazone_domain.main]
}

# Allow time for managed blueprints to become available after domain creation
resource "time_sleep" "domain_propagation" {
  depends_on      = [aws_datazone_domain.main]
  create_duration = "10s"
}

resource "awscc_datazone_environment_blueprint_configuration" "tooling" {
  domain_identifier                = aws_datazone_domain.main.id
  environment_blueprint_identifier = "Tooling"
  enabled_regions                  = [local.region]
  manage_access_role_arn           = local.manage_access_role_arn
  provisioning_role_arn            = local.provisioning_role_arn

  regional_parameters = [{
    region = local.region
    parameters = {
      "S3Location" = "s3://${var.s3_bucket_name}"
      "Subnets"    = join(",", var.subnet_ids)
      "VpcId"      = var.vpc_id
    }
  }]

  global_parameters = merge(
    var.query_execution_role_arn != null ? { sagemakerQueryExecutionRoleArn = var.query_execution_role_arn } : {},
    var.user_role_policy_arns != null ? { projectRolePolicyArns = join(",", var.user_role_policy_arns) } : {}
  )

  depends_on = [
    aws_iam_role.sagemaker_manage_access,
    aws_iam_role.sagemaker_provisioning,
    time_sleep.domain_propagation
  ]
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