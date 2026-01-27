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
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.id

  # Common tags for all IAM resources
  common_tags = merge(var.tags, {
    ManagedBy = "Terraform"
    Module    = "sagemaker-unified-studio-iam"
  })
}

#####################################################################################
# IAM roles and policies for SageMaker Unified Studio Blueprints
#####################################################################################

# SageMaker Manage Access Role (matches CloudFormation AmazonSageMakerManageAccessRole parameter)
resource "aws_iam_role" "sagemaker_manage_access" {
  count = var.create_sagemaker_roles ? 1 : 0

  name = var.sagemaker_manage_access_role_name != null ? var.sagemaker_manage_access_role_name : "${var.domain_name}-sagemaker-manage-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = [
            "datazone.amazonaws.com",
            "sagemaker.amazonaws.com"
          ]
        }
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

# SageMaker manage access role inline policy as separate resource
resource "aws_iam_role_policy" "sagemaker_manage_access_inline" {
  count = var.create_sagemaker_roles ? 1 : 0

  name = "smus_manage_access_policy"
  role = aws_iam_role.sagemaker_manage_access[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sagemaker:CreateDomain",
          "sagemaker:UpdateDomain",
          "sagemaker:DeleteDomain",
          "sagemaker:DescribeDomain",
          "sagemaker:ListDomains",
          "sagemaker:CreateUserProfile",
          "sagemaker:UpdateUserProfile",
          "sagemaker:DeleteUserProfile",
          "sagemaker:DescribeUserProfile",
          "sagemaker:ListUserProfiles",
          "sagemaker:CreateApp",
          "sagemaker:DeleteApp",
          "sagemaker:DescribeApp",
          "sagemaker:ListApps"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:sagemaker:${local.region}:${local.account_id}:domain/*",
          "arn:aws:sagemaker:${local.region}:${local.account_id}:user-profile/*",
          "arn:aws:sagemaker:${local.region}:${local.account_id}:app/*"
        ]
      },
      {
        Action = [
          "sagemaker:CreateProject",
          "sagemaker:UpdateProject",
          "sagemaker:DeleteProject",
          "sagemaker:DescribeProject",
          "sagemaker:ListProjects"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:sagemaker:${local.region}:${local.account_id}:project/*"
      },
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::sagemaker-*",
          "arn:aws:s3:::sagemaker-*/*",
          "arn:aws:s3:::${var.domain_name}-*",
          "arn:aws:s3:::${var.domain_name}-*/*"
        ]
      },
      {
        Action = "iam:PassRole"
        Effect = "Allow"
        Resource = [
          "arn:aws:iam::${local.account_id}:role/sagemaker-*",
          "arn:aws:iam::${local.account_id}:role/${var.domain_name}-*"
        ]
        Condition = {
          StringEquals = {
            "iam:PassedToService" = "sagemaker.amazonaws.com"
          }
        }
      }
    ]
  })
}

# Attach policies for SageMaker manage access role
resource "aws_iam_role_policy_attachment" "sagemaker_manage_access" {
  count = var.create_sagemaker_roles ? 1 : 0

  role       = aws_iam_role.sagemaker_manage_access[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDataZoneSageMakerManageAccessRolePolicy"
}

# SageMaker Provisioning Role (matches CloudFormation AmazonSageMakerProvisioningRole parameter)
resource "aws_iam_role" "sagemaker_provisioning" {
  count = var.create_sagemaker_roles ? 1 : 0

  name        = var.sagemaker_provisioning_role_name != null ? var.sagemaker_provisioning_role_name : "${var.domain_name}-sagemaker-provisioning-role"
  description = "IAM role to provision SageMaker environments"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["sts:AssumeRole", "sts:SetContext"]
        Effect = "Allow"
        Principal = {
          Service = [
            "datazone.amazonaws.com",
            "sagemaker.amazonaws.com",
            "cloudformation.amazonaws.com",
            "sts.amazonaws.com"
          ]
        }
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

# Attach policies for SageMaker provisioning role
resource "aws_iam_role_policy_attachment" "sagemaker_provisioning" {
  count = var.create_sagemaker_roles ? 1 : 0

  role       = aws_iam_role.sagemaker_provisioning[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/SageMakerStudioProjectProvisioningRolePolicy"
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
    var.create_sagemaker_roles ? aws_iam_role.sagemaker_manage_access[0].arn : var.manage_access_role_arn,
    var.create_sagemaker_roles ? aws_iam_role.sagemaker_provisioning[0].arn : var.provisioning_role_arn
  ])

  # Ensure this is created after the roles exist
  depends_on = [
    aws_iam_role.sagemaker_manage_access,
    aws_iam_role.sagemaker_provisioning
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

# Blueprint policy grants - create directly without local map
locals {
  # Only create policy grants for enabled blueprints
  enabled_blueprints = {
    for k, v in {
      "tooling"        = var.enable_tooling ? aws_datazone_environment_blueprint_configuration.tooling[0].environment_blueprint_id : null
      "data_lake"      = var.enable_data_lake ? aws_datazone_environment_blueprint_configuration.data_lake[0].environment_blueprint_id : null
      "data_warehouse" = var.enable_redshift_serverless ? aws_datazone_environment_blueprint_configuration.redshift_serverless[0].environment_blueprint_id : null
      "sagemaker"      = var.enable_sagemaker ? aws_datazone_environment_blueprint_configuration.sagemaker[0].environment_blueprint_id : null
    } : k => v if v != null
  }
}

# Tooling Blueprint (Required - provides shared infrastructure for other environments)
resource "aws_datazone_environment_blueprint_configuration" "tooling" {
  count = var.enable_tooling ? 1 : 0

  domain_id                = var.domain_id
  environment_blueprint_id = data.aws_datazone_environment_blueprint.Tooling.id
  manage_access_role_arn   = var.create_sagemaker_roles ? aws_iam_role.sagemaker_manage_access[0].arn : var.manage_access_role_arn
  provisioning_role_arn    = var.create_sagemaker_roles ? aws_iam_role.sagemaker_provisioning[0].arn : var.provisioning_role_arn
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
  manage_access_role_arn   = var.create_sagemaker_roles ? aws_iam_role.sagemaker_manage_access[0].arn : var.manage_access_role_arn
  provisioning_role_arn    = var.create_sagemaker_roles ? aws_iam_role.sagemaker_provisioning[0].arn : var.provisioning_role_arn
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
  manage_access_role_arn   = var.create_sagemaker_roles ? aws_iam_role.sagemaker_manage_access[0].arn : var.manage_access_role_arn
  provisioning_role_arn    = var.create_sagemaker_roles ? aws_iam_role.sagemaker_provisioning[0].arn : var.provisioning_role_arn
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
  manage_access_role_arn   = var.create_sagemaker_roles ? aws_iam_role.sagemaker_manage_access[0].arn : var.manage_access_role_arn
  provisioning_role_arn    = var.create_sagemaker_roles ? aws_iam_role.sagemaker_provisioning[0].arn : var.provisioning_role_arn
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
  manage_access_role_arn   = var.create_sagemaker_roles ? aws_iam_role.sagemaker_manage_access[0].arn : var.manage_access_role_arn
  provisioning_role_arn    = var.create_sagemaker_roles ? aws_iam_role.sagemaker_provisioning[0].arn : var.provisioning_role_arn
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