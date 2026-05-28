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

#####################################################################################
# Provider configuration
#
# Two AWS providers are configured: one for the source account (domain owner),
# one for the destination account (associated). Profile + region come from
# variables so callers can swap credentials per environment without editing
# code.
#
# AWSCC providers mirror the same configuration so AWSCC-typed resources land
# in the correct account.
#####################################################################################

# Default aws provider — source account (domain owner)
provider "aws" {
  region  = var.aws_region
  profile = var.source_profile

  default_tags {
    tags = {
      Project     = "SageMaker-Unified-Studio"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Example     = "cross-account"
    }
  }
}

# Aliased aws provider — destination (associated) account
provider "aws" {
  alias   = "associated"
  region  = var.aws_region
  profile = var.destination_profile

  default_tags {
    tags = {
      Project     = "SageMaker-Unified-Studio"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Example     = "cross-account"
    }
  }
}

# Default awscc provider — source account
provider "awscc" {
  region  = var.aws_region
  profile = var.source_profile
}

# Aliased awscc provider — destination account
provider "awscc" {
  alias   = "associated"
  region  = var.aws_region
  profile = var.destination_profile
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
  # region currently unused; uncomment if downstream code needs the active region
  # region = data.aws_region.current.region
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

}

#####################################################################################
# 2. Cross-Account Module
#    Shares the domain with the destination account via RAM and bootstraps
#    the destination account with the IAM roles needed for blueprints.
#####################################################################################

module "cross_account" {
  source = "../../modules/cross-account"

  providers = {
    aws.source      = aws
    aws.destination = aws.associated
  }

  domain_id           = module.domain.domain_id
  using_organizations = var.using_organizations
}
