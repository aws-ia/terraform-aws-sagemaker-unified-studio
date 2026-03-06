#####################################################################################
# Singular Blueprint Configuration Module
# Creates exactly one blueprint configuration per invocation.
# Invoke multiple times with different blueprint_name values.
#####################################################################################

######################################
# Data Sources
######################################

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Resolve blueprint ID from name
data "aws_datazone_environment_blueprint" "this" {
  domain_id = var.domain_id
  name      = var.blueprint_name
  managed   = true
}

# Lookup domain details
data "awscc_datazone_domain" "this" {
  id = var.domain_id
}

# Validate subnets are in the specified VPC
data "aws_subnet" "validation" {
  for_each = toset(var.subnet_ids)
  id       = each.value
}

######################################
# Locals
######################################

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.id

  manage_access_role_arn = var.manage_access_role_arn != null ? var.manage_access_role_arn : aws_iam_role.manage_access[0].arn
  provisioning_role_arn  = var.provisioning_role_arn != null ? var.provisioning_role_arn : "arn:aws:iam::${local.account_id}:role/service-role/AmazonSageMakerProvisioning-${local.account_id}"

  enabled_regions = var.enabled_regions != null ? var.enabled_regions : [local.region]

  # Build regional_parameters for each enabled region
  regional_parameters = {
    for r in local.enabled_regions : r => {
      "S3Location" = "s3://${var.s3_bucket_name}"
      "Subnets"    = join(",", var.subnet_ids)
      "VpcId"      = var.vpc_id
    }
  }

  common_tags = merge(var.tags, {
    ManagedBy = "Terraform"
    Module    = "sagemaker-unified-studio-blueprint"
  })
}

######################################
# Subnet VPC Membership Validation
######################################

resource "terraform_data" "subnet_vpc_validation" {
  for_each = data.aws_subnet.validation

  lifecycle {
    precondition {
      condition     = each.value.vpc_id == var.vpc_id
      error_message = "Subnet ${each.key} belongs to VPC ${each.value.vpc_id}, not ${var.vpc_id}."
    }
  }
}

######################################
# Conditional IAM Role Creation
######################################

# ManageAccess role — auto-created when manage_access_role_arn is null
resource "aws_iam_role" "manage_access" {
  count = var.manage_access_role_arn == null ? 1 : 0
  name  = "AmazonSageMakerManageAccess-${local.region}-${var.domain_id}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "datazone.amazonaws.com" }
      Action    = "sts:AssumeRole"
      Condition = {
        StringEquals = {
          "aws:SourceAccount" = local.account_id
        }
      }
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "manage_access_glue" {
  count      = var.manage_access_role_arn == null ? 1 : 0
  role       = aws_iam_role.manage_access[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDataZoneGlueManageAccessRolePolicy"
}

resource "aws_iam_role_policy_attachment" "manage_access_redshift" {
  count      = var.manage_access_role_arn == null ? 1 : 0
  role       = aws_iam_role.manage_access[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDataZoneRedshiftManageAccessRolePolicy"
}

resource "aws_iam_role_policy_attachment" "manage_access_sagemaker" {
  count      = var.manage_access_role_arn == null ? 1 : 0
  role       = aws_iam_role.manage_access[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDataZoneSageMakerAccess"
}

######################################
# Lake Formation Configuration
######################################

resource "aws_lakeformation_data_lake_settings" "main" {
  count = var.configure_lake_formation ? 1 : 0

  admins = compact([
    var.domain_execution_role_arn,
    local.manage_access_role_arn,
    local.provisioning_role_arn,
  ])

  depends_on = [
    aws_iam_role.manage_access
  ]
}

resource "time_sleep" "lakeformation_propagation" {
  count = var.configure_lake_formation ? 1 : 0

  depends_on      = [aws_lakeformation_data_lake_settings.main]
  create_duration = "30s"
}

######################################
# Single Blueprint Configuration
######################################

resource "aws_datazone_environment_blueprint_configuration" "this" {
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

######################################
# Policy Grant
######################################

resource "awscc_datazone_policy_grant" "this" {
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
          domain_unit                = var.domain_root_unit_id
          include_child_domain_units = true
        }
      }
    }
  }

  depends_on = [aws_datazone_environment_blueprint_configuration.this]
}
