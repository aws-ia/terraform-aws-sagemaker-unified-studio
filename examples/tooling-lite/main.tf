#####################################################################################
# SageMaker Unified Studio Quick-Setup Example
#
# Demonstrates the modular architecture:
#   1. Root domain module — creates domain, Tooling blueprint, IAM roles, S3 bucket,
#      model governance resources
#   2. Blueprint module (singular) — invoked per blueprint (LakehouseCatalog,
#      MLExperiments, RedshiftServerless)
#   3. Project profile module (singular) — composes blueprints into a deployable profile
#   4. Project module — creates a project from the profile
#
# Equivalent to the AWS console quick-setup experience.
#####################################################################################

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "SageMaker-Unified-Studio"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Example     = "quick-setup"
    }
  }
}

# Configure the AWS Cloud Control Provider (awscc) to use the same region
provider "awscc" {
  region = var.aws_region
}

#####################################################################################
# Data Sources
#####################################################################################

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Use default VPC/subnets when not explicitly provided
data "aws_vpc" "default" {
  count   = var.vpc_id == null ? 1 : 0
  default = true
}

data "aws_subnets" "default" {
  count = var.subnet_ids == null ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default[0].id]
  }
}

#####################################################################################
# Locals
#####################################################################################

locals {
  vpc_id     = var.vpc_id != null ? var.vpc_id : data.aws_vpc.default[0].id
  subnet_ids = var.subnet_ids != null ? var.subnet_ids : data.aws_subnets.default[0].ids
  region     = data.aws_region.current.id

  # Dynamic project name with random suffix for uniqueness
  project_name = "${var.project_name}-${random_id.project_suffix.hex}"

  common_tags = {
    DomainName  = var.domain_name
    Environment = var.environment
    Owner       = var.owner
    CreatedBy   = "terraform-quick-setup-example"
  }

  # Build the map of blueprints to enable based on toggle variables
  blueprint_configs = merge(
    // blueprints for bring your own role
    {
      tooling_lite = {
        blueprint_name = "ToolingLite"
      }
      s3_table_catalog = {
        blueprint_name = "S3TableCatalog"
      }
      s3_bucket = {
        blueprint_name = "S3Bucket"
      }
    }
  )
  default_blueprint_config = {
    "S3Bucket" = {
      deployment_mode = "ON_DEMAND"
      parameter_overrides = {
        "bucketName" = {
          value       = ""
          is_editable = true
        }
      }
    }
    "S3TableCatalog" = {
      deployment_mode = "ON_DEMAND"
      parameter_overrides = {
        "catalogName" = {
          value       = ""
          is_editable = true
        }
        "databaseName" = {
          value       = ""
          is_editable = true
        }
      }
    }
  }

  # Build the regional parameters for each blueprint (same VPC/subnets/S3 for all)
  regional_parameters = {
    (local.region) = {
      vpc_id     = local.vpc_id
      subnet_ids = local.subnet_ids
      s3_uri     = "s3://${module.domain.s3_bucket_name}"
    }
  }
}

resource "random_id" "project_suffix" {
  byte_length = 3
}

#####################################################################################
# 1. Domain Module
#    Creates the domain, Tooling blueprint, IAM roles, optional S3 bucket,
#    and model governance resources.
#    Demonstrates: Tooling blueprint integration (Req 9.3),
#                  model provisioning/consumption role config (Req 9.5),
#                  user role policy config (Req 9.6)
#####################################################################################

module "domain" {
  source = "../.."

  domain_name           = var.domain_name
  description           = var.domain_description
  vpc_id                = local.vpc_id
  subnet_ids            = local.subnet_ids
  s3_bucket_name        = var.s3_bucket_name
  user_role_policy_arns = var.user_role_policy_arns
  enable_sso            = var.enable_sso

  tags = local.common_tags
}

#####################################################################################
# 1a. Provisioning Role — additional inline policy
#     ToolingLite uses bring-your-own-role and creates the project S3 bucket at
#     project-creation time. The default provisioning role policy doesn't grant
#     s3:CreateBucket on amazon-sagemaker* buckets, so we attach an inline policy
#     here to fill that gap.
#####################################################################################

# The domain module exposes the provisioning role ARN; aws_iam_role_policy needs
# the role name, which is the last segment of the ARN (after stripping path).
locals {
  provisioning_role_name = reverse(split("/", module.domain.provisioning_role_arn))[0]
}



resource "aws_iam_role_policy_attachment" "provisioning_admin_policy_attachment" {
  role       = local.provisioning_role_name
  policy_arn = "arn:aws:iam::aws:policy/SageMakerStudioAdminIAMDefaultExecutionPolicy"
}

#####################################################################################
# 2. Blueprint Module (singular, invoked per blueprint)
#    Demonstrates: multiple blueprint invocations (Req 9.1),
#                  VPC configuration parameters (Req 9.4)
#####################################################################################

module "blueprints" {
  source   = "../../modules/blueprint"
  for_each = local.blueprint_configs

  domain_id      = module.domain.domain_id
  blueprint_name = each.value.blueprint_name

  regional_parameters = local.regional_parameters

  # Reuse roles created by the domain module
  manage_access_role_arn = module.domain.manage_access_role_arn
  provisioning_role_arn  = module.domain.provisioning_role_arn
  tags                   = local.common_tags
}

#####################################################################################
# 3. Project Profile Module (singular)
#    Demonstrates: blueprint dictionary composition (Req 9.2),
#                  Tooling blueprint integration from domain output (Req 9.3)
#####################################################################################

// BYOR Project Profile
module "default_project_profile" {
  source = "../../modules/project-profile"

  domain_id   = module.domain.domain_id
  name        = "Default Project Profile"
  description = "Default project profile with tooling capabilities"

  blueprints = local.default_blueprint_config

  blueprint_dependencies = [for k, bp in module.blueprints : bp.entity_id]
  toolinglite            = true
}

module "create_project_from_project_profile_grant" {
  source              = "../../modules/policy-grant/create_project"
  domain_id           = module.domain.domain_id
  domain_unit_id      = module.domain.domain_root_unit_id
  project_profile_ids = [module.default_project_profile.project_profile_id]
  all_users           = true
  depends_on = [module.default_project_profile
  ]
}


#####################################################################################
# 4. Project Module
#    Creates a project from the profile with SSO user membership
#####################################################################################


resource "random_string" "project_suffix" {
  length  = 8
  special = false
}
resource "aws_iam_role" "project_iam_role" {
  name = "SMUSProjectIAMExecutionRole_${random_string.project_suffix.result}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = [
            "datazone.amazonaws.com",
            "sagemaker.amazonaws.com",
            "glue.amazonaws.com",
            "bedrock.amazonaws.com",
            "scheduler.amazonaws.com",
            "lakeformation.amazonaws.com",
            "airflow-serverless.amazonaws.com",
            "athena.amazonaws.com",
            "redshift.amazonaws.com",
            "emr-serverless.amazonaws.com"
          ]
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession",
          "sts:SetContext",
          "sts:SetSourceIdentity"
        ]
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "project_iam_role_policy_attachment" {
  role       = aws_iam_role.project_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/SageMakerStudioUserIAMDefaultExecutionPolicy"
}

// Wait after role deployment for state to synchronize between aws and awscc
resource "time_sleep" "wait_after_project_role_creation" {
  depends_on      = [aws_iam_role.project_iam_role, aws_iam_role_policy_attachment.project_iam_role_policy_attachment]
  create_duration = "10s"
}


module "default_project" {
  source = "../../modules/project"

  domain_id           = module.domain.domain_id
  project_name        = var.project_name
  project_description = var.project_description
  // pick first available project profile
  project_profile_id = module.default_project_profile.project_profile_id
  project_role       = aws_iam_role.project_iam_role.arn

  depends_on = [module.create_project_from_project_profile_grant, aws_iam_role_policy_attachment.provisioning_admin_policy_attachment, time_sleep.wait_after_project_role_creation]
}

#####################################################################################
# 5. SSO User and Project Membership (Req 9.8)
#####################################################################################

resource "aws_datazone_user_profile" "sso_users" {
  for_each          = toset(var.sso_users)
  domain_identifier = module.domain.domain_id
  user_identifier   = each.key
  user_type         = "SSO_USER"
}

resource "awscc_datazone_project_membership" "project_membership" {
  for_each           = toset(var.sso_users)
  domain_identifier  = module.domain.domain_id
  project_identifier = module.default_project.project_id
  member = {
    user_identifier = each.key
  }
  designation = "PROJECT_OWNER"
}

module "project_membership" {
  for_each = toset(var.iam_users)
  source   = "../../modules/project/membership"

  domain_id   = module.domain.domain_id
  project_id  = module.default_project.project_id
  identifier  = each.key
  member_type = "IAM"
}

# Admin Project

module "admin_project" {
  source    = "../../modules/project/admin"
  domain_id = module.domain.domain_id
}

module "admin_project_membership" {
  for_each = toset(var.iam_users)
  source   = "../../modules/project/membership"

  domain_id   = module.domain.domain_id
  project_id  = module.admin_project.project_id
  identifier  = each.key
  member_type = "IAM"
}
