#####################################################################################
# Default Project Profile Module
# Enables ToolingLite, S3Bucket, S3TableCatalog blueprints and creates the
# special "Default Project Profile" used for bring-your-own-role projects.
#
# Provisioning role resolution (when var.using_admin_project = false):
#   1. var.provisioning_role_arn (if set)
#   2. Existing IAM role created by modules/blueprint/bootstrap, looked up by
#      the conventional name AmazonSageMakerProvisioning-<account_id>-<domain_id>
#   3. If neither is found, the module fails with a clear error
#
# When var.using_admin_project = true the provisioning_role_arn is left null on
# blueprint configurations so the admin project's execution role is used as
# the provisioner.
#
# Optional VPC configuration:
#   When var.vpc_id and var.subnet_ids are both provided, the ToolingLite
#   blueprint is enabled with VPC/Subnets regional parameters matching the
#   standard Tooling blueprint. Subnets are validated to belong to the VPC.
#####################################################################################

######################################
# Data Sources
######################################

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Look up the root domain unit ID for the policy grants below.
data "aws_datazone_domain" "main" {
  id = var.domain_id
}

# Look up the bootstrap-created provisioning role by name. The bootstrap
# submodule creates this role under the path /service-role/ with name
# AmazonSageMakerProvisioning-<account_id>-<domain_id>. The lookup always
# runs; the result is only used when the caller hasn't passed an explicit
# ARN AND admin project mode is off.
data "aws_iam_roles" "provisioning_role" {
  name_regex  = "^AmazonSageMakerProvisioning-${data.aws_caller_identity.current.account_id}-${var.domain_id}$"
  path_prefix = "/service-role/"
}

######################################
# Locals
######################################

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.id

  # Whether VPC + subnets were both provided. When true, ToolingLite is
  # configured with the same VPC/Subnets regional parameters used by the
  # standard Tooling blueprint.
  has_vpc_config = var.vpc_id != null && var.subnet_ids != null && length(coalesce(var.subnet_ids, [])) > 0

  # regional_parameters payload for the ToolingLite blueprint configuration.
  # Null when VPC/subnets weren't provided so the resource attribute is
  # omitted entirely.
  tooling_lite_regional_parameters = local.has_vpc_config ? {
    (local.region) = {
      "VpcId"   = var.vpc_id
      "Subnets" = join(",", var.subnet_ids)
    }
  } : null

  # Resolve the provisioning role ARN with the precedence described in the
  # module header. Returns null when admin project mode is on (so the admin
  # execution role acts as provisioner) OR when no role can be found.
  resolved_provisioning_role_arn = (
    var.using_admin_project ? null :
    var.provisioning_role_arn != null ? var.provisioning_role_arn :
    length(data.aws_iam_roles.provisioning_role.arns) > 0 ?
    tolist(data.aws_iam_roles.provisioning_role.arns)[0] :
    null
  )

  # Role name extracted from the ARN. IAM ARNs follow
  # arn:aws:iam::<acct>:role/[<path>/]<name>; the role name is the final
  # path segment. Used by the IAM policy attachment resource which requires
  # a name, not an ARN.
  provisioning_role_name = (
    local.resolved_provisioning_role_arn == null ? null :
    reverse(split("/", local.resolved_provisioning_role_arn))[0]
  )
}

######################################
# Subnet-in-VPC Validation
######################################

# Look up each subnet so we can verify it belongs to var.vpc_id. Only runs
# when both vpc_id and subnet_ids are provided.
data "aws_subnet" "validation" {
  for_each = local.has_vpc_config ? toset(var.subnet_ids) : toset([])
  id       = each.value
}

resource "terraform_data" "subnet_vpc_validation" {
  for_each = data.aws_subnet.validation

  lifecycle {
    precondition {
      condition     = each.value.vpc_id == var.vpc_id
      error_message = "Subnet ${each.value.id} belongs to VPC ${each.value.vpc_id}, not ${var.vpc_id}."
    }
  }
}

# Cross-variable check: vpc_id and subnet_ids must be set together.
resource "terraform_data" "vpc_config_validation" {
  lifecycle {
    precondition {
      condition     = (var.vpc_id == null) == (var.subnet_ids == null)
      error_message = "vpc_id and subnet_ids must be provided together. Provide both to enable ToolingLite VPC configuration, or neither to skip it."
    }
  }
}

######################################
# Provisioning role validation
######################################

# Fail the plan early if no provisioning role can be resolved when one is
# required (i.e. admin project mode is off and no ARN was provided/found).
resource "terraform_data" "provisioning_role_validation" {
  count = var.using_admin_project ? 0 : 1

  lifecycle {
    precondition {
      condition     = local.resolved_provisioning_role_arn != null
      error_message = "No provisioning role available for the default project profile. Either pass var.provisioning_role_arn, or run modules/blueprint/bootstrap to create AmazonSageMakerProvisioning-${data.aws_caller_identity.current.account_id}-${var.domain_id}, or set var.using_admin_project = true."
    }
  }
}

######################################
# Provisioning role: extra permissions
######################################

# When the admin project is not in use, the provisioning role needs additional
# permissions to set up default projects.
resource "aws_iam_role_policy_attachment" "provisioning_admin_policy_attachment" {
  count      = var.using_admin_project ? 0 : 1
  role       = local.provisioning_role_name
  policy_arn = "arn:aws:iam::aws:policy/SageMakerStudioAdminIAMDefaultExecutionPolicy"

  depends_on = [terraform_data.provisioning_role_validation]
}

######################################
# Blueprint Configurations
######################################

data "aws_datazone_environment_blueprint" "tooling_lite" {
  domain_id = var.domain_id
  name      = "ToolingLite"
  managed   = true
}

resource "aws_datazone_environment_blueprint_configuration" "tooling_lite" {
  domain_id                = var.domain_id
  environment_blueprint_id = data.aws_datazone_environment_blueprint.tooling_lite.id
  provisioning_role_arn    = local.resolved_provisioning_role_arn
  enabled_regions          = [local.region]
  regional_parameters      = local.tooling_lite_regional_parameters

  depends_on = [
    terraform_data.provisioning_role_validation,
    terraform_data.subnet_vpc_validation,
    terraform_data.vpc_config_validation,
  ]
}

data "aws_datazone_environment_blueprint" "s3_bucket" {
  domain_id = var.domain_id
  name      = "S3Bucket"
  managed   = true
}

resource "aws_datazone_environment_blueprint_configuration" "s3_bucket" {
  domain_id                = var.domain_id
  environment_blueprint_id = data.aws_datazone_environment_blueprint.s3_bucket.id
  provisioning_role_arn    = local.resolved_provisioning_role_arn
  enabled_regions          = [local.region]

  depends_on = [aws_datazone_environment_blueprint_configuration.tooling_lite]
}

data "aws_datazone_environment_blueprint" "s3_table_catalog" {
  domain_id = var.domain_id
  name      = "S3TableCatalog"
  managed   = true
}

resource "aws_datazone_environment_blueprint_configuration" "s3_table_catalog" {
  domain_id                = var.domain_id
  environment_blueprint_id = data.aws_datazone_environment_blueprint.s3_table_catalog.id
  provisioning_role_arn    = local.resolved_provisioning_role_arn
  enabled_regions          = [local.region]

  depends_on = [aws_datazone_environment_blueprint_configuration.s3_bucket]
}

######################################
# Policy Grants
######################################

resource "awscc_datazone_policy_grant" "tooling_lite_policy_grant" {
  domain_identifier = var.domain_id
  entity_type       = "ENVIRONMENT_BLUEPRINT_CONFIGURATION"
  entity_identifier = "${local.account_id}:${data.aws_datazone_environment_blueprint.tooling_lite.id}"
  policy_type       = "CREATE_ENVIRONMENT_FROM_BLUEPRINT"

  detail = {
    create_environment_from_blueprint = jsonencode({})
  }

  principal = {
    project = {
      project_designation = "CONTRIBUTOR"
      project_grant_filter = {
        domain_unit_filter = {
          domain_unit                = data.aws_datazone_domain.main.root_domain_unit_id
          include_child_domain_units = true
        }
      }
    }
  }

  depends_on = [aws_datazone_environment_blueprint_configuration.tooling_lite]
}

resource "awscc_datazone_policy_grant" "s3_table_catalog_policy_grant" {
  domain_identifier = var.domain_id
  entity_type       = "ENVIRONMENT_BLUEPRINT_CONFIGURATION"
  entity_identifier = "${local.account_id}:${data.aws_datazone_environment_blueprint.s3_table_catalog.id}"
  policy_type       = "CREATE_ENVIRONMENT_FROM_BLUEPRINT"

  detail = {
    create_environment_from_blueprint = jsonencode({})
  }

  principal = {
    project = {
      project_designation = "CONTRIBUTOR"
      project_grant_filter = {
        domain_unit_filter = {
          domain_unit                = data.aws_datazone_domain.main.root_domain_unit_id
          include_child_domain_units = true
        }
      }
    }
  }

  depends_on = [aws_datazone_environment_blueprint_configuration.s3_table_catalog]
}

resource "awscc_datazone_policy_grant" "s3_bucket_policy_grant" {
  domain_identifier = var.domain_id
  entity_type       = "ENVIRONMENT_BLUEPRINT_CONFIGURATION"
  entity_identifier = "${local.account_id}:${data.aws_datazone_environment_blueprint.s3_bucket.id}"
  policy_type       = "CREATE_ENVIRONMENT_FROM_BLUEPRINT"

  detail = {
    create_environment_from_blueprint = jsonencode({})
  }

  principal = {
    project = {
      project_designation = "CONTRIBUTOR"
      project_grant_filter = {
        domain_unit_filter = {
          domain_unit                = data.aws_datazone_domain.main.root_domain_unit_id
          include_child_domain_units = true
        }
      }
    }
  }

  depends_on = [aws_datazone_environment_blueprint_configuration.s3_bucket]
}

######################################
# Default Project Profile
######################################

resource "awscc_datazone_project_profile" "this" {
  name                   = "Default Project Profile"
  description            = "Default project profile with tooling capabilities"
  domain_identifier      = var.domain_id
  domain_unit_identifier = data.aws_datazone_domain.main.root_domain_unit_id
  status                 = "ENABLED"

  environment_configurations = [
    {
      name                     = "ToolingLite"
      environment_blueprint_id = data.aws_datazone_environment_blueprint.tooling_lite.id
      deployment_mode          = "ON_CREATE"
      deployment_order         = 0
      aws_account = {
        aws_account_id = local.account_id
      }
      aws_region = {
        region_name = local.region
      }
      configuration_parameters = {
        parameter_overrides = [
          {
            name        = "s3BucketLocation"
            value       = ""
            is_editable = true
          }
        ]
      }
    },
    {
      name                     = "S3Bucket"
      environment_blueprint_id = data.aws_datazone_environment_blueprint.s3_bucket.id
      deployment_mode          = "ON_DEMAND"
      aws_account = {
        aws_account_id = local.account_id
      }
      aws_region = {
        region_name = local.region
      }
      configuration_parameters = {
        parameter_overrides = [
          {
            name        = "bucketName"
            is_editable = true
          }
        ]
      }
    },
    {
      name                     = "S3TableCatalog"
      environment_blueprint_id = data.aws_datazone_environment_blueprint.s3_table_catalog.id
      deployment_mode          = "ON_DEMAND"
      aws_account = {
        aws_account_id = local.account_id
      }
      aws_region = {
        region_name = local.region
      }
      configuration_parameters = {
        parameter_overrides = [
          {
            name        = "catalogName"
            value       = ""
            is_editable = true
          },
          {
            name        = "databaseName"
            value       = ""
            is_editable = true
          }
        ]
      }
    }
  ]

  depends_on = [
    aws_datazone_environment_blueprint_configuration.tooling_lite,
    aws_datazone_environment_blueprint_configuration.s3_bucket,
    aws_datazone_environment_blueprint_configuration.s3_table_catalog,
    awscc_datazone_policy_grant.tooling_lite_policy_grant,
    awscc_datazone_policy_grant.s3_bucket_policy_grant,
    awscc_datazone_policy_grant.s3_table_catalog_policy_grant,
    aws_iam_role_policy_attachment.provisioning_admin_policy_attachment,
  ]
}
