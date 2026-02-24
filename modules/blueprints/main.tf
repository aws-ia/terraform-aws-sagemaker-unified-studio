#####################################################################################
# SageMaker Unified Studio Blueprint Configuration Module
# This module enables environment blueprints for the domain
# Uses actual blueprint IDs available in DataZone
#####################################################################################

######################################
# Defaults and Locals
######################################

# Data sources for current context
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Local values
locals {
  account_id       = data.aws_caller_identity.current.account_id
  region           = data.aws_region.current.id
  domain_id_suffix = replace(var.domain_id, "/^dzd-/", "") # Strip dzd- prefix for resource naming (e.g., dzd-abc123example -> abc123example)

  # Default provisioning role name (matches console-created role)
  default_provisioning_role_name = "AmazonSageMakerProvisioning-${local.account_id}"

  provisioning_role_exists = var.provisioning_role_arn != null ? true : length(data.aws_iam_roles.provisioning_role.arns) > 0

  # Determine final role ARN: user-provided > existing > newly created
  provisioning_role_arn = var.provisioning_role_arn != null ? var.provisioning_role_arn : (
    local.provisioning_role_exists ? tolist(data.aws_iam_roles.provisioning_role.arns)[0] : aws_iam_role.sagemaker_provisioning[0].arn
  )

  # Manage access role: domain-scoped name, shared across blueprints for the same domain
  # Note: name is hardcoded to match the console-created convention (not user-configurable)
  # Existence check (separate from provisioning_role_exists above) needed so second blueprint
  # call for the same domain finds the role and skips creation
  default_manage_access_role_name = "AmazonSageMakerManageAccess-${local.region}-${var.domain_id}"
  manage_access_role_exists = var.manage_access_role_arn != null ? true : length(data.aws_iam_roles.manage_access_role.arns) > 0
  manage_access_role_arn    = var.manage_access_role_arn != null ? var.manage_access_role_arn : (
    local.manage_access_role_exists ? tolist(data.aws_iam_roles.manage_access_role.arns)[0] : aws_iam_role.sagemaker_manage_access[0].arn
  )
  
  # Common tags for all IAM resources
  common_tags = merge(var.tags, {
    ManagedBy = "Terraform"
    Module    = "sagemaker-unified-studio-iam"
  })
}

#####################################################################################
# IAM roles and policies for SageMaker Unified Studio Blueprints
#####################################################################################

# Look up AmazonSageMakerProvisioning role — returns empty list if not found
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
            "aws:SourceAccount" = local.account_id
          }
        }
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "sagemaker_provisioning" {
  count      = !local.provisioning_role_exists ? 1 : 0
  role       = aws_iam_role.sagemaker_provisioning[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDataZoneSageMakerProvisioningRolePolicy"
}

resource "aws_iam_role" "sagemaker_manage_access" {
  count = !local.manage_access_role_exists ? 1 : 0
  
  name = "AmazonSageMakerManageAccess-${local.region}-${var.domain_id}"
  description = "This role grants Amazon SageMaker Unified Studio permissions to publish, grant access, and revoke access to Amazon SageMaker Lakehouse, AWS Glue Data Catalog and Amazon Redshift data. It also grants Amazon SageMaker Unified Studio to publish and manage subscriptions on Amazon SageMaker Catalog data and AI assets."
  
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
          ArnEquals = {
            "aws:SourceArn" = "arn:aws:datazone:${local.region}:${local.account_id}:domain/${var.domain_root_unit_id}"
          }
        }
      }
    ]
  })

  tags = local.common_tags
}

# Customer managed policy for Redshift secret access (matches console-created policy)
resource "aws_iam_policy" "sagemaker_manage_access_redshift" {
  count = !local.manage_access_role_exists ? 1 : 0

  name = "AmazonSageMakerManageAccessPolicy-${local.domain_id_suffix}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "RedshiftSecretStatement"
        Effect = "Allow"
        Action = "secretsmanager:GetSecretValue"
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

# Attach AWS managed policies for SageMaker manage access role
resource "aws_iam_role_policy_attachment" "sagemaker_manage_access" {
  count = !local.manage_access_role_exists ? 1 : 0
  
  role       = aws_iam_role.sagemaker_manage_access[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDataZoneSageMakerManageAccessRolePolicy"
}

resource "aws_iam_role_policy_attachment" "glue_manage_access" {
  count = !local.manage_access_role_exists ? 1 : 0

  role       = aws_iam_role.sagemaker_manage_access[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDataZoneGlueManageAccessRolePolicy"
}

resource "aws_iam_role_policy_attachment" "redshift_manage_access" {
  count = !local.manage_access_role_exists ? 1 : 0

  role       = aws_iam_role.sagemaker_manage_access[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDataZoneRedshiftManageAccessRolePolicy"
}

#####################################################################################
# Lake Formation Configuration
# Grant Lake Formation admin permissions BEFORE blueprint configurations
# This ensures roles have proper permissions when environments are auto-created
#####################################################################################

resource "aws_lakeformation_data_lake_settings" "main" {
  count = var.configure_lake_formation ? 1 : 0

  admins = compact([
    var.domain_execution_role_arn,
    local.manage_access_role_arn,
    local.provisioning_role_arn,
  ])

  # Ensure this is created after the roles exist
  depends_on = [
    aws_iam_role.sagemaker_manage_access
  ]
}

# Wait for Lake Formation settings to propagate before proceeding
# This ensures permissions are fully active before environments are created
resource "time_sleep" "lakeformation_propagation" {
  count = var.configure_lake_formation ? 1 : 0

  depends_on = [aws_lakeformation_data_lake_settings.main]

  create_duration = "30s"
}

#####################################################################################
# Blueprints creation and configuration
#####################################################################################

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

# Static blueprint map for policy grants
locals {
  blueprint_map = {
    "tooling"        = data.aws_datazone_environment_blueprint.Tooling.id
    "data_lake"      = data.aws_datazone_environment_blueprint.LakehouseCatalog.id
    "data_warehouse" = data.aws_datazone_environment_blueprint.RedshiftServerless.id
    "sagemaker"      = data.aws_datazone_environment_blueprint.MLExperiments.id
  }
  
  enabled_blueprints = {
    for k, v in local.blueprint_map : k => v if (
      (k == "tooling" && var.enable_tooling) ||
      (k == "data_lake" && var.enable_data_lake) ||
      (k == "data_warehouse" && var.enable_redshift_serverless) ||
      (k == "sagemaker" && var.enable_sagemaker)
    )
  }
}

# Tooling Blueprint (Required - provides shared infrastructure for other environments)
resource "aws_datazone_environment_blueprint_configuration" "tooling" {
  count = var.enable_tooling ? 1 : 0

  domain_id                = var.domain_id
  environment_blueprint_id = data.aws_datazone_environment_blueprint.Tooling.id
  manage_access_role_arn   = local.manage_access_role_arn
  provisioning_role_arn    = local.provisioning_role_arn

  enabled_regions          = [data.aws_region.current.id]

  # Regional parameters for Tooling blueprint
  regional_parameters = {
    (data.aws_region.current.id) = {
      "S3Location" = "s3://${var.s3_bucket_name}"
      "Subnets"    = join(",", var.subnet_ids)
      "VpcId"      = var.vpc_id
    }
  }

  # Ensure Lake Formation permissions are set before creating blueprint configurations
  depends_on = [
    time_sleep.lakeformation_propagation
  ]
}

# Lakehouse Catalog Blueprint (V2 - Essential for data catalog and lake functionality)
resource "aws_datazone_environment_blueprint_configuration" "data_lake" {
  count = var.enable_data_lake ? 1 : 0

  domain_id                = var.domain_id
  environment_blueprint_id = data.aws_datazone_environment_blueprint.LakehouseCatalog.id
  manage_access_role_arn   = local.manage_access_role_arn
  provisioning_role_arn    = local.provisioning_role_arn
  enabled_regions          = [data.aws_region.current.id]

  # Regional parameters for Lakehouse Catalog blueprint
  regional_parameters = {
    (data.aws_region.current.id) = {
      "S3Location" = "s3://${var.s3_bucket_name}"
      "Subnets"    = join(",", var.subnet_ids)
      "VpcId"      = var.vpc_id
    }
  }

  # Ensure Lake Formation permissions are set before creating blueprint configurations
  depends_on = [
    time_sleep.lakeformation_propagation
  ]
}

# Redshift Serverless Blueprint (V2 - Essential for analytics)
resource "aws_datazone_environment_blueprint_configuration" "redshift_serverless" {
  count = var.enable_redshift_serverless ? 1 : 0

  domain_id                = var.domain_id
  environment_blueprint_id = data.aws_datazone_environment_blueprint.RedshiftServerless.id
  manage_access_role_arn   = local.manage_access_role_arn
  provisioning_role_arn    = local.provisioning_role_arn
  enabled_regions          = [data.aws_region.current.id]

  # Regional parameters for Redshift Serverless blueprint
  regional_parameters = {
    (data.aws_region.current.id) = {
      "S3Location" = "s3://${var.s3_bucket_name}"
      "Subnets"    = join(",", var.subnet_ids)
      "VpcId"      = var.vpc_id
    }
  }

  # Ensure Lake Formation permissions are set before creating blueprint configurations
  depends_on = [
    time_sleep.lakeformation_propagation
  ]
}

# ML Experiments Blueprint (V2 - Essential for ML workloads)
resource "aws_datazone_environment_blueprint_configuration" "sagemaker" {
  count = var.enable_sagemaker ? 1 : 0

  domain_id                = var.domain_id
  environment_blueprint_id = data.aws_datazone_environment_blueprint.MLExperiments.id
  manage_access_role_arn   = local.manage_access_role_arn
  provisioning_role_arn    = local.provisioning_role_arn
  enabled_regions          = [data.aws_region.current.id]

  # Regional parameters for ML Experiments blueprint
  regional_parameters = {
    (data.aws_region.current.id) = {
      "S3Location" = "s3://${var.s3_bucket_name}"
      "Subnets"    = join(",", var.subnet_ids)
      "VpcId"      = var.vpc_id
    }
  }

  # Ensure Lake Formation permissions are set before creating blueprint configurations
  depends_on = [
    time_sleep.lakeformation_propagation
  ]
}

# Custom AWS Service Blueprint (Optional for custom integrations)
resource "aws_datazone_environment_blueprint_configuration" "custom_aws_service" {
  count = var.enable_custom_aws_service ? 1 : 0

  domain_id                = var.domain_id
  environment_blueprint_id = "afiyksudw9nzv4" # CustomAwsService
  manage_access_role_arn   = local.manage_access_role_arn
  provisioning_role_arn    = local.provisioning_role_arn
  enabled_regions          = [data.aws_region.current.id]

  # Regional parameters for Custom AWS Service blueprint (minimal)
  regional_parameters = {
    (data.aws_region.current.id) = {}
  }

  # Ensure Lake Formation permissions are set before creating blueprint configurations
  depends_on = [
    time_sleep.lakeformation_propagation
  ]
}

resource "awscc_datazone_policy_grant" "blueprint_policy_grants" {
  for_each          = local.enabled_blueprints
  domain_identifier = var.domain_id
  entity_type       = "ENVIRONMENT_BLUEPRINT_CONFIGURATION"
  entity_identifier = "${data.aws_caller_identity.current.account_id}:${each.value}"
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

  depends_on = [
    aws_datazone_environment_blueprint_configuration.tooling,
    aws_datazone_environment_blueprint_configuration.data_lake,
    aws_datazone_environment_blueprint_configuration.redshift_serverless,
    aws_datazone_environment_blueprint_configuration.sagemaker
  ]
}