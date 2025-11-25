# SageMaker Unified Studio Blueprint Configuration Module
# This module enables environment blueprints for the domain
# Uses actual blueprint IDs available in DataZone

# Data sources for current context
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_datazone_environment_blueprint" "default_data_lake" {
  domain_id = var.domain_id
  name      = "DataLake"
  managed   = true
}

data "aws_datazone_environment_blueprint" "LakehouseCatalog" {
  domain_id = var.domain_id
  name      = "LakehouseCatalog"
  managed   = true
}

data "aws_datazone_environment_blueprint" "Tooling" {
  domain_id = var.domain_id
  name      = "Tooling"
  managed   = true
}

data "aws_datazone_environment_blueprint" "RedshiftServerless" {
  domain_id = var.domain_id
  name      = "RedshiftServerless"
  managed   = true
}

data "aws_datazone_environment_blueprint" "MLExperiments" {
  domain_id = var.domain_id
  name      = "MLExperiments"
  managed   = true
}

# Array of blueprint IDs for iteration
locals {
  blueprint_ids = [
    data.aws_datazone_environment_blueprint.Tooling.id,
    data.aws_datazone_environment_blueprint.LakehouseCatalog.id,
    data.aws_datazone_environment_blueprint.RedshiftServerless.id,
    data.aws_datazone_environment_blueprint.MLExperiments.id,
    "afiyksudw9nzv4" # CustomAwsService
  ]
}

# Tooling Blueprint (Required - provides shared infrastructure for other environments)
resource "aws_datazone_environment_blueprint_configuration" "tooling" {
  count = var.enable_tooling ? 1 : 0

  domain_id                = var.domain_id
  environment_blueprint_id = data.aws_datazone_environment_blueprint.Tooling.id
  manage_access_role_arn   = var.manage_access_role_arn
  provisioning_role_arn    = var.provisioning_role_arn
  enabled_regions          = [data.aws_region.current.id]

  # Regional parameters for Tooling blueprint
  regional_parameters = {
    (data.aws_region.current.id) = {
      "S3Location" = "s3://${var.s3_bucket_name}"
      "Subnets"    = join(",", var.subnet_ids)
      "VpcId"      = var.vpc_id
    }
  }
}

# Lakehouse Catalog Blueprint (V2 - Essential for data catalog and lake functionality)
resource "aws_datazone_environment_blueprint_configuration" "data_lake" {
  count = var.enable_data_lake ? 1 : 0

  domain_id                = var.domain_id
  environment_blueprint_id = data.aws_datazone_environment_blueprint.LakehouseCatalog.id
  manage_access_role_arn   = var.manage_access_role_arn
  provisioning_role_arn    = var.provisioning_role_arn
  enabled_regions          = [data.aws_region.current.id]

  # Regional parameters for Lakehouse Catalog blueprint
  regional_parameters = {
    (data.aws_region.current.id) = {
      "S3Location" = "s3://${var.s3_bucket_name}"
      "Subnets"    = join(",", var.subnet_ids)
      "VpcId"      = var.vpc_id
    }
  }
}

# Redshift Serverless Blueprint (V2 - Essential for analytics)
resource "aws_datazone_environment_blueprint_configuration" "redshift_serverless" {
  count = var.enable_redshift_serverless ? 1 : 0

  domain_id                = var.domain_id
  environment_blueprint_id = data.aws_datazone_environment_blueprint.RedshiftServerless.id
  manage_access_role_arn   = var.manage_access_role_arn
  provisioning_role_arn    = var.provisioning_role_arn
  enabled_regions          = [data.aws_region.current.id]

  # Regional parameters for Redshift Serverless blueprint
  regional_parameters = {
    (data.aws_region.current.id) = {
      "S3Location" = "s3://${var.s3_bucket_name}"
      "Subnets"    = join(",", var.subnet_ids)
      "VpcId"      = var.vpc_id
    }
  }
}

# ML Experiments Blueprint (V2 - Essential for ML workloads)
resource "aws_datazone_environment_blueprint_configuration" "sagemaker" {
  count = var.enable_sagemaker ? 1 : 0

  domain_id                = var.domain_id
  environment_blueprint_id = data.aws_datazone_environment_blueprint.MLExperiments.id
  manage_access_role_arn   = var.manage_access_role_arn
  provisioning_role_arn    = var.provisioning_role_arn
  enabled_regions          = [data.aws_region.current.id]

  # Regional parameters for ML Experiments blueprint
  regional_parameters = {
    (data.aws_region.current.id) = {
      "S3Location" = "s3://${var.s3_bucket_name}"
      "Subnets"    = join(",", var.subnet_ids)
      "VpcId"      = var.vpc_id
    }
  }
}

# Custom AWS Service Blueprint (Optional for custom integrations)
resource "aws_datazone_environment_blueprint_configuration" "custom_aws_service" {
  count = var.enable_custom_aws_service ? 1 : 0

  domain_id                = var.domain_id
  environment_blueprint_id = "afiyksudw9nzv4" # CustomAwsService
  manage_access_role_arn   = var.manage_access_role_arn
  provisioning_role_arn    = var.provisioning_role_arn
  enabled_regions          = [data.aws_region.current.id]

  # Regional parameters for Custom AWS Service blueprint (minimal)
  regional_parameters = {
    (data.aws_region.current.id) = {}
  }
}

resource "awscc_datazone_policy_grant" "blueprint_policy_grants" {
  for_each = locals.blueprint_ids
  domain_identifier = var.domain_id
  entity_type = "ENVIRONMENT_BLUEPRINT_CONFIGURATION"
  entity_identifier = "${data.aws_caller_identity.current.account_id}:${each.value}"
  policy_type  = "CREATE_ENVIRONMENT_FROM_BLUEPRINT"
  detail = {
     create_environment_from_blueprint = jsonencode({})
   }
  principal = {
    project = {
      project_designation = "CONTRIBUTOR"
      project_grant_filter = {
        domain_unit_filter = {
          domain_unit  = var.domain_id
          include_child_domain_units  = true
         }
       }
     }
   }
}