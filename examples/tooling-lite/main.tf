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



# Admin Project

module "admin_project" {
  count     = var.create_admin_portal ? 1 : 0
  source    = "../../modules/project/admin"
  domain_id = module.domain.domain_id
}

#####################################################################################
# 2. Membership wiring
#
# Three principal sets feed three target projects:
#   - domain_admins        -> admin project (PROJECT_OWNER), only when create_admin_portal = true
#   - project_owners       -> default project (PROJECT_OWNER)
#   - project_contributors -> default project (PROJECT_CONTRIBUTOR)
#
# Each set accepts SSO users, SSO groups, IAM users, and IAM roles. IAM user ARNs
# are mapped to member_type IAM_USER and IAM role ARNs to IAM_ROLE. SSO users are
# registered as user profiles in the domain so they can be added as members.
#####################################################################################

locals {
  # Flatten each principal set into [{ key, member_type, identifier, role }] tuples
  # so we can drive a single for_each per role.
  domain_admin_members = concat(
    [for u in var.domain_admins.sso_users : { key = "sso_user.${u}", member_type = "SSO_USER", identifier = u }],
    [for g in var.domain_admins.sso_groups : { key = "sso_group.${g}", member_type = "SSO_GROUP", identifier = g }],
    [for a in var.domain_admins.iam_users : { key = "iam_user.${a}", member_type = "IAM_USER", identifier = a }],
    [for a in var.domain_admins.iam_roles : { key = "iam_role.${a}", member_type = "IAM_ROLE", identifier = a }],
  )

  project_owner_members = concat(
    [for u in var.project_owners.sso_users : { key = "sso_user.${u}", member_type = "SSO_USER", identifier = u }],
    [for g in var.project_owners.sso_groups : { key = "sso_group.${g}", member_type = "SSO_GROUP", identifier = g }],
    [for a in var.project_owners.iam_users : { key = "iam_user.${a}", member_type = "IAM_USER", identifier = a }],
    [for a in var.project_owners.iam_roles : { key = "iam_role.${a}", member_type = "IAM_ROLE", identifier = a }],
  )

  project_contributor_members = concat(
    [for u in var.project_contributors.sso_users : { key = "sso_user.${u}", member_type = "SSO_USER", identifier = u }],
    [for g in var.project_contributors.sso_groups : { key = "sso_group.${g}", member_type = "SSO_GROUP", identifier = g }],
    [for a in var.project_contributors.iam_users : { key = "iam_user.${a}", member_type = "IAM_USER", identifier = a }],
    [for a in var.project_contributors.iam_roles : { key = "iam_role.${a}", member_type = "IAM_ROLE", identifier = a }],
  )

  # Union of every SSO user across the three principal sets. Each unique user
  # needs an aws_datazone_user_profile created so they can be added as a
  # project member.
  all_sso_users = toset(concat(
    var.domain_admins.sso_users,
    var.project_owners.sso_users,
    var.project_contributors.sso_users,
  ))
}

# Register each SSO user as a domain user profile.
resource "aws_datazone_user_profile" "sso_users" {
  for_each          = local.all_sso_users
  domain_identifier = module.domain.domain_id
  user_identifier   = each.key
  user_type         = "SSO_USER"
}

# Validation: domain_admins memberships only make sense when the admin portal
# is enabled. Without this guard, indexing into module.admin_project[0] would
# fail with a less helpful error.
resource "terraform_data" "admin_project_membership_precondition" {
  count = length(local.domain_admin_members) > 0 ? 1 : 0

  lifecycle {
    precondition {
      condition     = var.create_admin_portal
      error_message = "domain_admins may only be set when create_admin_portal = true. Either enable the admin portal, or move these principals into project_owners / project_contributors."
    }
  }
}

# Admin project memberships (PROJECT_OWNER on the admin project).
module "admin_project_membership" {
  for_each = var.create_admin_portal ? { for m in local.domain_admin_members : m.key => m } : {}
  source   = "../../modules/project/membership"

  domain_id    = module.domain.domain_id
  project_id   = module.admin_project[0].project_id
  member_type  = each.value.member_type
  identifier   = each.value.identifier
  project_role = "PROJECT_OWNER"

  depends_on = [
    terraform_data.admin_project_membership_precondition,
    aws_datazone_user_profile.sso_users,
  ]
}


#####################################################################################
# 3. Project Profile Module (singular)
#    Demonstrates: blueprint dictionary composition (Req 9.2),
#                  Tooling blueprint integration from domain output (Req 9.3)
#####################################################################################

// BYOR Project Profile

module "default_project_profile" {
  source = "../../modules/project-profile/default"

  domain_id             = module.domain.domain_id
  provisioning_role_arn = module.domain.provisioning_role_arn
  vpc_id                = var.vpc_id
  subnet_ids            = var.subnet_ids
  using_admin_project   = var.create_admin_portal
  depends_on            = [module.admin_project]
}

module "create_project_from_project_profile_grant" {
  source              = "../../modules/policy-grant/create_project"
  domain_id           = module.domain.domain_id
  domain_unit_id      = module.domain.domain_root_unit_id
  project_profile_ids = [module.default_project_profile.project_profile_id]
  all_users           = true
  depends_on          = [module.default_project_profile]
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
  count = var.project_role_arn == null ? 1 : 0
  name  = "SMUSProjectIAMExecutionRole_${random_string.project_suffix.result}"
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
  count      = var.project_role_arn == null ? 1 : 0
  role       = aws_iam_role.project_iam_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/SageMakerStudioUserIAMDefaultExecutionPolicy"
}

# Allow the project execution role to be passed to the SMUS-integrated services.
resource "aws_iam_role_policy" "project_iam_role_pass_role" {
  count = var.project_role_arn == null ? 1 : 0
  name  = "PassRole"
  role  = aws_iam_role.project_iam_role[0].name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "PassRole"
        Effect   = "Allow"
        Action   = ["iam:PassRole"]
        Resource = aws_iam_role.project_iam_role[0].arn
        Condition = {
          StringEquals = {
            "aws:ResourceAccount" = "$${aws:PrincipalAccount}"
            "iam:PassedToService" = [
              "bedrock.amazonaws.com",
              "glue.amazonaws.com",
              "lakeformation.amazonaws.com",
              "sagemaker.amazonaws.com",
              "scheduler.amazonaws.com",
              "emr-serverless.amazonaws.com",
              "elasticmapreduce.amazonaws.com",
              "redshift.amazonaws.com",
              "airflow-serverless.amazonaws.com"
            ]
          }
        }
      }
    ]
  })
}

// Wait after role deployment for state to synchronize between aws and awscc
resource "time_sleep" "wait_after_project_role_creation" {
  count           = var.project_role_arn == null ? 1 : 0
  depends_on      = [aws_iam_role.project_iam_role, aws_iam_role_policy_attachment.project_iam_role_policy_attachment, aws_iam_role_policy.project_iam_role_pass_role]
  create_duration = "10s"
}

locals {
  # Bring-your-own-role: when project_role_arn is provided, use it as-is.
  # Otherwise fall back to the IAM role created by this example.
  project_role_arn = var.project_role_arn != null ? var.project_role_arn : aws_iam_role.project_iam_role[0].arn
}


module "default_project" {
  source = "../../modules/project"

  domain_id           = module.domain.domain_id
  project_name        = var.project_name
  project_description = var.project_description
  // pick first available project profile
  project_profile_id = module.default_project_profile.project_profile_id
  project_role       = local.project_role_arn

  depends_on = [module.create_project_from_project_profile_grant, time_sleep.wait_after_project_role_creation]
}

#####################################################################################
# 5. Default project memberships
#####################################################################################

module "project_owner_membership" {
  for_each = { for m in local.project_owner_members : m.key => m }
  source   = "../../modules/project/membership"

  domain_id    = module.domain.domain_id
  project_id   = module.default_project.project_id
  member_type  = each.value.member_type
  identifier   = each.value.identifier
  project_role = "PROJECT_OWNER"

  depends_on = [aws_datazone_user_profile.sso_users]
}

module "project_contributor_membership" {
  for_each = { for m in local.project_contributor_members : m.key => m }
  source   = "../../modules/project/membership"

  domain_id    = module.domain.domain_id
  project_id   = module.default_project.project_id
  member_type  = each.value.member_type
  identifier   = each.value.identifier
  project_role = "PROJECT_CONTRIBUTOR"

  depends_on = [aws_datazone_user_profile.sso_users]
}
