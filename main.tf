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

resource "random_string" "suffix" {
  length  = 8
  special = false
}

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.id

  # Generate dynamic domain name if not provided
  domain_name = var.domain_name != null ? var.domain_name : "domain-${formatdate("MM-DD-YYYY-HHmmss", timestamp())}"

  # Default role names for SageMaker Unified Studio
  default_domain_execution_role_name = "AmazonSageMakerDomainExecution${random_string.suffix.result}"
  default_domain_service_role_name   = "AmazonSageMakerDomainService${random_string.suffix.result}"

  # Role creation: count driven by variable only (not data source) to avoid flip-flop.
  # Data sources are used only for ARN resolution when role pre-exists outside Terraform.
  create_domain_execution_role = var.domain_execution_role_arn == null
  create_domain_service_role   = var.domain_service_role_arn == null

  # 3-tier ARN resolution: user-provided > pre-existing in AWS > Terraform-managed
  domain_execution_role_arn = var.domain_execution_role_arn != null ? var.domain_execution_role_arn : (
    length(data.aws_iam_roles.domain_execution_role.arns) > 0 ? tolist(data.aws_iam_roles.domain_execution_role.arns)[0] : aws_iam_role.domain_execution[0].arn
  )

  domain_service_role_arn = var.domain_service_role_arn != null ? var.domain_service_role_arn : (
    length(data.aws_iam_roles.domain_service_role.arns) > 0 ? tolist(data.aws_iam_roles.domain_service_role.arns)[0] : aws_iam_role.domain_service[0].arn
  )

  # Blueprint role ARNs — resolved from bootstrap module or user-provided
  provisioning_role_arn  = var.provisioning_role_arn != null ? var.provisioning_role_arn : module.bootstrap.provisioning_role_arn
  manage_access_role_arn = var.manage_access_role_arn != null ? var.manage_access_role_arn : module.bootstrap.manage_access_role_arn

  # Query execution role — user-provided or auto-created
  query_execution_role_arn = var.query_execution_role_arn != null ? var.query_execution_role_arn : aws_iam_role.query_execution[0].arn
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
  count = local.create_domain_execution_role ? 1 : 0

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
          "sts:TagSession",
          "sts:SetContext"
        ]
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = local.account_id
          }
          "ForAllValues:StringLike" = {
            "aws:TagKeys" = "datazone*"
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
  count      = local.create_domain_execution_role ? 1 : 0
  role       = aws_iam_role.domain_execution[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/SageMakerStudioDomainExecutionRolePolicy"
}

# Create AmazonSageMakerDomainService role if it doesn't exist
resource "aws_iam_role" "domain_service" {
  count = local.create_domain_service_role ? 1 : 0

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
    Purpose   = "SageMaker-Unified-Studio-Domain-Service"
  })
}

# Attach the managed policy to domain service role
resource "aws_iam_role_policy_attachment" "domain_service_policy" {
  count      = local.create_domain_service_role ? 1 : 0
  role       = aws_iam_role.domain_service[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/SageMakerStudioDomainServiceRolePolicy"
}

#####################################################################################
# Query Execution Role (optional, auto-created when not provided)
#####################################################################################

resource "aws_iam_role" "query_execution" {
  count = var.query_execution_role_arn == null ? 1 : 0

  name = "AmazonSageMakerQueryExecution${random_string.suffix.result}"
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
    Purpose   = "SageMaker-Unified-Studio-QueryExecution"
  })
}

resource "aws_iam_role_policy_attachment" "query_execution_policy" {
  count      = var.query_execution_role_arn == null ? 1 : 0
  role       = aws_iam_role.query_execution[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/SageMakerStudioQueryExecutionRolePolicy"
}

#####################################################################################
# Blueprint IAM Roles — Provisioning and Manage Access (R3)
# Delegated to the bootstrap submodule for role creation.
# Outputs are available for other blueprint modules to consume.
#####################################################################################

module "bootstrap" {
  source = "./modules/blueprint/bootstrap"

  domain_id                 = aws_datazone_domain.main.id
  create_provisioning_role  = var.provisioning_role_arn == null
  create_manage_access_role = var.manage_access_role_arn == null
  configure_lake_formation  = true
  tags                      = var.tags
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

  # Tie the domain execution/service roles (and their policy attachments) to the
  # domain lifecycle. The domain already references the role ARNs implicitly, but
  # the policy attachments do not — without this, Terraform could remove the
  # attachments before destroying the domain. Declaring the dependency here forces:
  #   - create: roles + policy attachments are fully provisioned BEFORE the domain
  #   - destroy: the domain is deleted BEFORE its roles/attachments are removed
  # No dependency cycle is created because the roles/attachments never reference
  # the domain.
  depends_on = [
    aws_iam_role.domain_execution,
    aws_iam_role.domain_service,
    aws_iam_role_policy_attachment.domain_execution_policy,
    aws_iam_role_policy_attachment.domain_service_policy,
  ]
}

# Data source needed to get root domain unit
data "aws_datazone_domain" "main" {
  id = aws_datazone_domain.main.id
}

#####################################################################################
# Optional S3 Bucket (R3-AC7)
# Created when var.s3_bucket_name is null
#####################################################################################

locals {
  s3_bucket_name = var.s3_bucket_name != null ? var.s3_bucket_name : aws_s3_bucket.domain[0].id
}

#checkov:skip=CKV2_AWS_61:Lifecycle configuration not required for tooling storage
#checkov:skip=CKV2_AWS_62:Event notifications not required for tooling storage
#checkov:skip=CKV_AWS_144:Cross-region replication not required for tooling storage
#tfsec:ignore:aws-s3-enable-versioning
resource "aws_s3_bucket" "domain" {
  count  = var.s3_bucket_name == null ? 1 : 0
  bucket = lower("sagemaker-studio-${local.account_id}-${local.region}-${random_string.suffix.result}")

  #checkov:skip=CKV2_AWS_61:Lifecycle configuration not required for tooling storage
  #checkov:skip=CKV2_AWS_62:Event notifications not required for tooling storage
  #checkov:skip=CKV_AWS_144:Cross-region replication not required for tooling storage
  #checkov:skip=CKV_AWS_21:Versioning not required for tooling storage since data lakes will be stored

  tags = merge(var.tags, {
    Purpose = "SageMaker Unified Studio Domain Storage"
  })
}

#tfsec:ignore:aws-s3-encryption-customer-key
resource "aws_s3_bucket_server_side_encryption_configuration" "domain" {
  count  = var.s3_bucket_name == null ? 1 : 0
  bucket = aws_s3_bucket.domain[0].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.kms_key_identifier != null ? "aws:kms" : "AES256"
      kms_master_key_id = var.kms_key_identifier
    }
  }
}

resource "aws_s3_bucket_logging" "domain" {
  count         = var.s3_bucket_name == null ? 1 : 0
  bucket        = aws_s3_bucket.domain[0].id
  target_bucket = aws_s3_bucket.domain[0].id
  target_prefix = "access-logs/"
}

resource "aws_s3_bucket_public_access_block" "domain" {
  count                   = var.s3_bucket_name == null ? 1 : 0
  bucket                  = aws_s3_bucket.domain[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#####################################################################################
# Tooling Blueprint Configuration (R3 + R8)
# Delegated to the blueprint module for consistent blueprint management.
#####################################################################################

module "tooling_blueprint" {
  source = "./modules/blueprint"

  domain_id      = aws_datazone_domain.main.id
  blueprint_name = "Tooling"

  regional_parameters = {
    (local.region) = {
      vpc_id     = var.vpc_id
      subnet_ids = var.subnet_ids
      s3_uri     = "s3://${local.s3_bucket_name}"
    }
  }

  global_parameters = merge(
    { sagemakerQueryExecutionRoleArn = local.query_execution_role_arn },
    var.user_role_policy_arns != null ? { projectRolePolicyArns = join(",", var.user_role_policy_arns) } : {}
  )

  manage_access_role_arn = local.manage_access_role_arn
  provisioning_role_arn  = local.provisioning_role_arn
  tags                   = var.tags
}

# Deploy hidden project and project profile used to govern/enable bedrock models
resource "awscc_datazone_project_profile" "model_governance_project_profile" {
  name                   = "Generative AI model governance"
  description            = "Govern generative AI models powered by Amazon Bedrock"
  status                 = "ENABLED"
  domain_identifier      = aws_datazone_domain.main.id
  domain_unit_identifier = data.aws_datazone_domain.main.root_domain_unit_id
}

resource "awscc_datazone_project" "model_governance_project" {
  domain_identifier  = aws_datazone_domain.main.id
  name               = "GenerativeAIModelGovernanceProject"
  project_profile_id = awscc_datazone_project_profile.model_governance_project_profile.project_profile_id
}
