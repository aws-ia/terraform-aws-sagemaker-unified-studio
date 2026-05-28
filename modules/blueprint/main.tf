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

# Data source needed to get root domain unit
data "aws_datazone_domain" "main" {
  id = var.domain_id
}

# Resolve blueprint ID from name
data "aws_datazone_environment_blueprint" "this" {
  domain_id = var.domain_id
  name      = var.blueprint_name
  managed   = true
}

# Flatten all subnet IDs across regions for VPC validation
locals {
  subnet_region_pairs = flatten([
    for region, params in var.regional_parameters : [
      for subnet_id in params.subnet_ids : {
        key       = "${region}:${subnet_id}"
        region    = region
        subnet_id = subnet_id
        vpc_id    = params.vpc_id
      }
    ]
  ])
  subnet_validation_map = { for pair in local.subnet_region_pairs : pair.key => pair }
}

# Validate subnets are in the specified VPC (only when regional params are used)
data "aws_subnet" "validation" {
  for_each = local.subnet_validation_map
  id       = each.value.subnet_id
  region   = each.value.region
}

######################################
# Locals
######################################

locals {
  account_id       = data.aws_caller_identity.current.account_id
  region           = data.aws_region.current.region
  domain_id_suffix = replace(var.domain_id, "/^dzd-/", "")
  domain_account_id = var.domain_account_id != null ? var.domain_account_id : local.account_id

  enabled_regions = length(var.regional_parameters) > 0 ? keys(var.regional_parameters) : [local.region]

  # Whether this blueprint uses regional parameters
  has_regional_parameters = length(var.regional_parameters) > 0

  # Whether this blueprint uses global parameters
  has_global_parameters = length(var.global_parameters) > 0

  # 2-tier role resolution: user-provided > data lookup > fail
  default_provisioning_role_name  = "AmazonSageMakerProvisioning-${local.account_id}-${var.domain_id}"
  default_manage_access_role_name = "AmazonSageMakerManageAccess-${local.region}-${var.domain_id}"

  provisioning_role_exists = var.provisioning_role_arn != null ? true : length(data.aws_iam_roles.provisioning_role.arns) > 0
  provisioning_role_arn = var.provisioning_role_arn != null ? var.provisioning_role_arn : (
    length(data.aws_iam_roles.provisioning_role.arns) > 0 ? tolist(data.aws_iam_roles.provisioning_role.arns)[0] : null
  )

  manage_access_role_exists = var.manage_access_role_arn != null ? true : length(data.aws_iam_roles.manage_access_role.arns) > 0
  manage_access_role_arn = var.manage_access_role_arn != null ? var.manage_access_role_arn : (
    length(data.aws_iam_roles.manage_access_role.arns) > 0 ? tolist(data.aws_iam_roles.manage_access_role.arns)[0] : null
  )

  common_tags = merge(var.tags, {
    ManagedBy = "Terraform"
    Module    = "sagemaker-unified-studio-blueprint"
  })

  # Build regional_parameters for each enabled region (only when blueprint needs them)
  regional_parameters = local.has_regional_parameters ? {
    for r, params in var.regional_parameters : r => {
      "S3Location" = params.s3_uri
      "Subnets"    = join(",", params.subnet_ids)
      "VpcId"      = params.vpc_id
    }
  } : null

  awscc_formatted_regional_parameters = [
    for r, params in var.regional_parameters : {
      region = r
      parameters = {
        "S3Location" = params.s3_uri
        "Subnets"    = join(",", params.subnet_ids)
        "VpcId"      = params.vpc_id
      }
    }
  ]

  # Resolve domain unit IDs: user-provided list, or fall back to root domain unit
  effective_domain_unit_ids = length(var.domain_unit_ids) > 0 ? toset(var.domain_unit_ids) : toset([data.aws_datazone_domain.main.root_domain_unit_id])
}

######################################
# Subnet-in-VPC Validation
######################################

resource "terraform_data" "subnet_vpc_validation" {
  for_each = data.aws_subnet.validation

  lifecycle {
    precondition {
      condition     = each.value.vpc_id == local.subnet_validation_map[each.key].vpc_id
      error_message = "Subnet ${each.value.id} belongs to VPC ${each.value.vpc_id}, not ${local.subnet_validation_map[each.key].vpc_id}."
    }
  }
}

######################################
# IAM Role Lookup
######################################

data "aws_iam_roles" "provisioning_role" {
  name_regex = "^AmazonSageMakerProvisioning-${local.account_id}$"
}

data "aws_iam_roles" "manage_access_role" {
  name_regex = "^${local.default_manage_access_role_name}$"
}

######################################
# Role Existence Validation
######################################

resource "terraform_data" "provisioning_role_validation" {
  lifecycle {
    precondition {
      condition     = local.provisioning_role_arn != null
      error_message = "Provisioning role '${local.default_provisioning_role_name}' not found. Please create it first using the bootstrap submodule (modules/blueprint/bootstrap) or pass var.provisioning_role_arn explicitly."
    }
  }
}

resource "terraform_data" "manage_access_role_validation" {
  lifecycle {
    precondition {
      condition     = local.manage_access_role_arn != null
      error_message = "Manage access role '${local.default_manage_access_role_name}' not found. Please create it first using the bootstrap submodule (modules/blueprint/bootstrap) or pass var.manage_access_role_arn explicitly."
    }
  }
}

######################################
# Blueprint Configuration (singular)
######################################

resource "aws_datazone_environment_blueprint_configuration" "this" {
  count                    = local.has_global_parameters ? 0 : 1
  domain_id                = var.domain_id
  environment_blueprint_id = data.aws_datazone_environment_blueprint.this.id
  manage_access_role_arn   = local.manage_access_role_arn
  provisioning_role_arn    = local.provisioning_role_arn
  enabled_regions          = local.enabled_regions
  regional_parameters      = local.regional_parameters

  depends_on = [
    terraform_data.subnet_vpc_validation,
    terraform_data.provisioning_role_validation,
    terraform_data.manage_access_role_validation,
  ]
}

resource "awscc_datazone_environment_blueprint_configuration" "this" {
  count                            = local.has_global_parameters ? 1 : 0
  domain_identifier                = var.domain_id
  environment_blueprint_identifier = var.blueprint_name
  enabled_regions                  = local.enabled_regions
  manage_access_role_arn           = local.manage_access_role_arn
  provisioning_role_arn            = local.provisioning_role_arn

  regional_parameters = local.awscc_formatted_regional_parameters

  global_parameters = var.global_parameters

  depends_on = [
    terraform_data.subnet_vpc_validation,
    terraform_data.provisioning_role_validation,
    terraform_data.manage_access_role_validation,
  ]
}

######################################
# Policy Grant
######################################

resource "awscc_datazone_policy_grant" "this" {
  count = length(var.domain_unit_ids) > 0 ? length(var.domain_unit_ids) : 1

  domain_identifier = var.domain_id
  entity_type       = "ENVIRONMENT_BLUEPRINT_CONFIGURATION"
  entity_identifier = "${local.account_id}:${data.aws_datazone_environment_blueprint.this.id}"
  policy_type       = "CREATE_ENVIRONMENT_FROM_BLUEPRINT"

  detail = {
    create_environment_from_blueprint = jsonencode({})
  }

  principal = {
    project = {
      project_designation = "CONTRIBUTOR"
      project_grant_filter = {
        domain_unit_filter = {
          domain_unit                = length(var.domain_unit_ids) > 0 ? var.domain_unit_ids[count.index] : data.aws_datazone_domain.main.root_domain_unit_id
          include_child_domain_units = true
        }
      }
    }
  }

  depends_on = [aws_datazone_environment_blueprint_configuration.this, awscc_datazone_environment_blueprint_configuration.this]
}

######################################
# Propagation Wait
######################################

resource "time_sleep" "blueprint_propagation" {
  depends_on      = [awscc_datazone_policy_grant.this]
  create_duration = "5s"
}
