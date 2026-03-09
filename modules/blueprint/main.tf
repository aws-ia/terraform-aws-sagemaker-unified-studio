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
  region           = data.aws_region.current.id
  domain_id_suffix = replace(var.domain_id, "/^dzd-/", "")
  domain_account_id = var.domain_account_id != null ? var.domain_account_id : local.account_id

  enabled_regions = length(var.regional_parameters) > 0 ? keys(var.regional_parameters) : [local.region]

  # Whether this blueprint uses regional parameters
  has_regional_parameters = length(var.regional_parameters) > 0

  # Whether this blueprint uses global parameters
  has_global_parameters = length(var.global_parameters) > 0

  # 3-tier role resolution: user-provided > existing > auto-create
  default_provisioning_role_name = "AmazonSageMakerProvisioning-${local.account_id}"
  provisioning_role_exists       = var.provisioning_role_arn != null ? true : length(data.aws_iam_roles.provisioning_role.arns) > 0
  provisioning_role_arn = var.provisioning_role_arn != null ? var.provisioning_role_arn : (
    local.provisioning_role_exists ? tolist(data.aws_iam_roles.provisioning_role.arns)[0] : aws_iam_role.sagemaker_provisioning[0].arn
  )

  default_manage_access_role_name = "AmazonSageMakerManageAccess-${local.region}-${var.domain_id}"
  manage_access_role_exists       = var.manage_access_role_arn != null ? true : length(data.aws_iam_roles.manage_access_role.arns) > 0
  manage_access_role_arn = var.manage_access_role_arn != null ? var.manage_access_role_arn : (
    local.manage_access_role_exists ? tolist(data.aws_iam_roles.manage_access_role.arns)[0] : aws_iam_role.sagemaker_manage_access[0].arn
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
# IAM Role Lookup and Creation (from R4)
######################################

data "aws_iam_roles" "provisioning_role" {
  name_regex = "^AmazonSageMakerProvisioning-${local.account_id}$"
}

data "aws_iam_roles" "manage_access_role" {
  name_regex = "^${local.default_manage_access_role_name}$"
}

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
            "aws:SourceAccount" = local.domain_account_id
          }
        }
      }
    ]
  })

  lifecycle {
    prevent_destroy = true
  }

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "sagemaker_provisioning" {
  count      = !local.provisioning_role_exists ? 1 : 0
  role       = aws_iam_role.sagemaker_provisioning[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDataZoneSageMakerProvisioningRolePolicy"
}

# Create ManageAccess role if it doesn't exist
resource "aws_iam_role" "sagemaker_manage_access" {
  count = !local.manage_access_role_exists ? 1 : 0

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

  lifecycle {
    prevent_destroy = true
  }

  tags = local.common_tags
}

# Custom Redshift secret access policy
resource "aws_iam_policy" "sagemaker_manage_access_redshift" {
  count = !local.manage_access_role_exists ? 1 : 0

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
  count      = !local.manage_access_role_exists ? 1 : 0
  role       = aws_iam_role.sagemaker_manage_access[0].name
  policy_arn = aws_iam_policy.sagemaker_manage_access_redshift[0].arn
}

resource "aws_iam_role_policy_attachment" "sagemaker_manage_access" {
  count      = !local.manage_access_role_exists ? 1 : 0
  role       = aws_iam_role.sagemaker_manage_access[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDataZoneSageMakerManageAccessRolePolicy"
}

resource "aws_iam_role_policy_attachment" "glue_manage_access" {
  count      = !local.manage_access_role_exists ? 1 : 0
  role       = aws_iam_role.sagemaker_manage_access[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDataZoneGlueManageAccessRolePolicy"
}

resource "aws_iam_role_policy_attachment" "redshift_manage_access" {
  count      = !local.manage_access_role_exists ? 1 : 0
  role       = aws_iam_role.sagemaker_manage_access[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDataZoneRedshiftManageAccessRolePolicy"
}

######################################
# Lake Formation Configuration (from R4)
######################################

resource "aws_lakeformation_data_lake_settings" "main" {
  count = var.configure_lake_formation ? 1 : 0

  admins = compact([
    var.domain_execution_role_arn,
    local.manage_access_role_arn,
    local.provisioning_role_arn,
  ])

  lifecycle {
    prevent_destroy = true
  }

  depends_on = [
    aws_iam_role.sagemaker_manage_access
  ]
}

resource "time_sleep" "lakeformation_propagation" {
  count = var.configure_lake_formation ? 1 : 0

  depends_on      = [aws_lakeformation_data_lake_settings.main]
  create_duration = "30s"
}

######################################
# Blueprint Configuration (singular)
######################################

# Warn if blueprint is already configured and allow_replace_existing is false.
# The scoped data source inside the check block is independent of the resource
# lifecycle — if the config doesn't exist (404), the check simply warns.
check "existing_blueprint_configuration" {
  data "awscc_datazone_environment_blueprint_configuration" "existing" {
    id = "${var.domain_id}|${data.aws_datazone_environment_blueprint.this.id}"
  }

  assert {
    condition     = var.allow_replace_existing || length(data.awscc_datazone_environment_blueprint_configuration.existing.enabled_regions) == 0
    error_message = "Blueprint '${var.blueprint_name}' is already configured for domain ${var.domain_id}. Set allow_replace_existing = true to replace the existing configuration."
  }
}

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
    time_sleep.lakeformation_propagation
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
    time_sleep.lakeformation_propagation
  ]
}

######################################
# Policy Grant
######################################

resource "awscc_datazone_policy_grant" "this" {
  for_each = local.effective_domain_unit_ids

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
          domain_unit                = each.value
          include_child_domain_units = true
        }
      }
    }
  }

  depends_on = [aws_datazone_environment_blueprint_configuration.this, awscc_datazone_environment_blueprint_configuration.this]
}
