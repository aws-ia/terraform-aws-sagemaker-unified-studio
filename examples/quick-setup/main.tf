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
    var.enable_lakehouse_catalog ? {
      lakehouse_catalog = {
        blueprint_name = "LakehouseCatalog"
      }
    } : {},
    var.enable_ml_experiments ? {
      ml_experiments = {
        blueprint_name = "MLExperiments"
      }
    } : {},
    var.enable_redshift_serverless ? {
      redshift_serverless = {
        blueprint_name = "RedshiftServerless"
      }
    } : {},
  )

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
  manage_access_role_arn    = module.domain.manage_access_role_arn
  provisioning_role_arn     = module.domain.provisioning_role_arn
  domain_execution_role_arn = module.domain.domain_execution_role_arn
  configure_lake_formation  = true

  # Allow replacing existing blueprint configurations
  allow_replace_existing = true

  tags = local.common_tags

  depends_on = [module.domain]
}

#####################################################################################
# 3. Project Profile Module (singular)
#    Demonstrates: blueprint dictionary composition (Req 9.2),
#                  Tooling blueprint integration from domain output (Req 9.3)
#####################################################################################

module "project_profile" {
  source = "../../modules/project-profile"

  domain_id = module.domain.domain_id
  name      = "${var.domain_name}-quick-setup-profile"

  # Compose blueprints into the profile — Tooling is automatically included
  # and always first in the environment configurations
  blueprints = {
    for key, config in local.blueprint_configs : config.blueprint_name => {}
  }

  depends_on = [module.blueprints]
}

#####################################################################################
# 4. Project Module
#    Creates a project from the profile with SSO user membership
#####################################################################################

module "project" {
  source = "../../modules/project"

  domain_id           = module.domain.domain_id
  project_name        = local.project_name
  project_description = var.project_description
  project_profile_id  = module.project_profile.project_profile_id

  depends_on = [module.project_profile]
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
  project_identifier = module.project.project_id
  member = {
    user_identifier = each.key
  }
  designation = "PROJECT_OWNER"
}
