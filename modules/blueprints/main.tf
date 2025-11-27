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
        Effect = "Allow"
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
}

# Policy grants to authorize domain unit to use blueprint configurations
# This matches the Python example: datazone.add_policy_grant(domainIdentifier=domain_id,entityType="EnvironmentBlueprintConfiguration",entityIdentifier=f"{account_id}:{blueprint_id}",...)
resource "null_resource" "blueprint_authorization" {
  depends_on = [
    aws_datazone_environment_blueprint_configuration.tooling,
    aws_datazone_environment_blueprint_configuration.data_lake,
    aws_datazone_environment_blueprint_configuration.redshift_serverless,
    aws_datazone_environment_blueprint_configuration.sagemaker,
    aws_datazone_environment_blueprint_configuration.custom_aws_service
  ]

  provisioner "local-exec" {
    command = <<-EOT
      echo "Adding blueprint authorization policy grants..."
      
      # Get the root domain unit ID from the domain
      ROOT_DOMAIN_UNIT_ID=$(aws datazone get-domain --identifier ${var.domain_id} --region ${data.aws_region.current.id} --query 'rootDomainUnitId' --output text)
      ACCOUNT_ID=${data.aws_caller_identity.current.account_id}
      echo "Using root domain unit ID: $ROOT_DOMAIN_UNIT_ID"
      echo "Using account ID: $ACCOUNT_ID"
      
      # Tooling blueprint authorization (matches Python format: account_id:blueprint_id)
      ${var.enable_tooling ? "aws datazone add-policy-grant --domain-identifier ${var.domain_id} --entity-type ENVIRONMENT_BLUEPRINT_CONFIGURATION --entity-identifier $ACCOUNT_ID:${aws_datazone_environment_blueprint_configuration.tooling[0].environment_blueprint_id} --policy-type CREATE_ENVIRONMENT_FROM_BLUEPRINT --principal '{\"project\": {\"projectGrantFilter\": {\"domainUnitFilter\": {\"domainUnit\": \"'$ROOT_DOMAIN_UNIT_ID'\", \"includeChildDomainUnits\": true}}, \"projectDesignation\": \"CONTRIBUTOR\"}}' --detail '{\"createEnvironmentFromBlueprint\":{}}' --region ${data.aws_region.current.id} || echo 'Tooling blueprint grant may already exist'" : "echo 'Tooling blueprint disabled'"}
      
      # Data Lake blueprint authorization  
      ${var.enable_data_lake ? "aws datazone add-policy-grant --domain-identifier ${var.domain_id} --entity-type ENVIRONMENT_BLUEPRINT_CONFIGURATION --entity-identifier $ACCOUNT_ID:${aws_datazone_environment_blueprint_configuration.data_lake[0].environment_blueprint_id} --policy-type CREATE_ENVIRONMENT_FROM_BLUEPRINT --principal '{\"project\": {\"projectGrantFilter\": {\"domainUnitFilter\": {\"domainUnit\": \"'$ROOT_DOMAIN_UNIT_ID'\", \"includeChildDomainUnits\": true}}, \"projectDesignation\": \"CONTRIBUTOR\"}}' --detail '{\"createEnvironmentFromBlueprint\":{}}' --region ${data.aws_region.current.id} || echo 'Data Lake blueprint grant may already exist'" : "echo 'Data Lake blueprint disabled'"}
      
      # Redshift Serverless blueprint authorization
      ${var.enable_redshift_serverless ? "aws datazone add-policy-grant --domain-identifier ${var.domain_id} --entity-type ENVIRONMENT_BLUEPRINT_CONFIGURATION --entity-identifier $ACCOUNT_ID:${aws_datazone_environment_blueprint_configuration.redshift_serverless[0].environment_blueprint_id} --policy-type CREATE_ENVIRONMENT_FROM_BLUEPRINT --principal '{\"project\": {\"projectGrantFilter\": {\"domainUnitFilter\": {\"domainUnit\": \"'$ROOT_DOMAIN_UNIT_ID'\", \"includeChildDomainUnits\": true}}, \"projectDesignation\": \"CONTRIBUTOR\"}}' --detail '{\"createEnvironmentFromBlueprint\":{}}' --region ${data.aws_region.current.id} || echo 'Redshift blueprint grant may already exist'" : "echo 'Redshift blueprint disabled'"}
      
      # SageMaker blueprint authorization
      ${var.enable_sagemaker ? "aws datazone add-policy-grant --domain-identifier ${var.domain_id} --entity-type ENVIRONMENT_BLUEPRINT_CONFIGURATION --entity-identifier $ACCOUNT_ID:${aws_datazone_environment_blueprint_configuration.sagemaker[0].environment_blueprint_id} --policy-type CREATE_ENVIRONMENT_FROM_BLUEPRINT --principal '{\"project\": {\"projectGrantFilter\": {\"domainUnitFilter\": {\"domainUnit\": \"'$ROOT_DOMAIN_UNIT_ID'\", \"includeChildDomainUnits\": true}}, \"projectDesignation\": \"CONTRIBUTOR\"}}' --detail '{\"createEnvironmentFromBlueprint\":{}}' --region ${data.aws_region.current.id} || echo 'SageMaker blueprint grant may already exist'" : "echo 'SageMaker blueprint disabled'"}
      
      # Custom AWS Service blueprint authorization
      ${var.enable_custom_aws_service ? "aws datazone add-policy-grant --domain-identifier ${var.domain_id} --entity-type ENVIRONMENT_BLUEPRINT_CONFIGURATION --entity-identifier $ACCOUNT_ID:${aws_datazone_environment_blueprint_configuration.custom_aws_service[0].environment_blueprint_id} --policy-type CREATE_ENVIRONMENT_FROM_BLUEPRINT --principal '{\"project\": {\"projectGrantFilter\": {\"domainUnitFilter\": {\"domainUnit\": \"'$ROOT_DOMAIN_UNIT_ID'\", \"includeChildDomainUnits\": true}}, \"projectDesignation\": \"CONTRIBUTOR\"}}' --detail '{\"createEnvironmentFromBlueprint\":{}}' --region ${data.aws_region.current.id} || echo 'Custom AWS Service blueprint grant may already exist'" : "echo 'Custom AWS Service blueprint disabled'"}
      
      echo "Blueprint authorization completed"
    EOT
  }
}

# Validation resource to verify policy grants are working
resource "null_resource" "validate_blueprint_grants" {
  depends_on = [null_resource.blueprint_authorization]

  provisioner "local-exec" {
    command = <<-EOT
      echo "Validating blueprint policy grants..."
      
      ACCOUNT_ID=${data.aws_caller_identity.current.account_id}
      
      # Validate each enabled blueprint has proper grants
      ${var.enable_tooling ? "echo 'Checking Tooling blueprint grants...' && aws datazone list-policy-grants --domain-identifier ${var.domain_id} --entity-type ENVIRONMENT_BLUEPRINT_CONFIGURATION --entity-identifier $ACCOUNT_ID:${aws_datazone_environment_blueprint_configuration.tooling[0].environment_blueprint_id} --policy-type CREATE_ENVIRONMENT_FROM_BLUEPRINT --region ${data.aws_region.current.id} --query 'grantList[0].principal' || echo 'Tooling blueprint validation failed'" : "echo 'Tooling blueprint not enabled'"}
      
      ${var.enable_data_lake ? "echo 'Checking Data Lake blueprint grants...' && aws datazone list-policy-grants --domain-identifier ${var.domain_id} --entity-type ENVIRONMENT_BLUEPRINT_CONFIGURATION --entity-identifier $ACCOUNT_ID:${aws_datazone_environment_blueprint_configuration.data_lake[0].environment_blueprint_id} --policy-type CREATE_ENVIRONMENT_FROM_BLUEPRINT --region ${data.aws_region.current.id} --query 'grantList[0].principal' || echo 'Data Lake blueprint validation failed'" : "echo 'Data Lake blueprint not enabled'"}
      
      ${var.enable_redshift_serverless ? "echo 'Checking Redshift blueprint grants...' && aws datazone list-policy-grants --domain-identifier ${var.domain_id} --entity-type ENVIRONMENT_BLUEPRINT_CONFIGURATION --entity-identifier $ACCOUNT_ID:${aws_datazone_environment_blueprint_configuration.redshift_serverless[0].environment_blueprint_id} --policy-type CREATE_ENVIRONMENT_FROM_BLUEPRINT --region ${data.aws_region.current.id} --query 'grantList[0].principal' || echo 'Redshift blueprint validation failed'" : "echo 'Redshift blueprint not enabled'"}
      
      ${var.enable_sagemaker ? "echo 'Checking SageMaker blueprint grants...' && aws datazone list-policy-grants --domain-identifier ${var.domain_id} --entity-type ENVIRONMENT_BLUEPRINT_CONFIGURATION --entity-identifier $ACCOUNT_ID:${aws_datazone_environment_blueprint_configuration.sagemaker[0].environment_blueprint_id} --policy-type CREATE_ENVIRONMENT_FROM_BLUEPRINT --region ${data.aws_region.current.id} --query 'grantList[0].principal' || echo 'SageMaker blueprint validation failed'" : "echo 'SageMaker blueprint not enabled'"}
      
      echo "Blueprint grant validation completed"
    EOT
  }
}
