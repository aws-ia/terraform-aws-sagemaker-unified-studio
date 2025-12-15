# SageMaker Unified Studio MVP Example
# This example combines domain creation and project setup in a single configuration
# Equivalent to deploying both basic-domain and single-account-project examples together

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "SageMaker-Unified-Studio"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Example     = "mvp"
    }
  }
}

# Configure the AWS Cloud Control Provider (awscc) to use the same region
provider "awscc" {
  region = var.aws_region
}

# Data sources for current context
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Get default VPC and subnets for testing
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Local values for resource naming and tagging
locals {
  # Generate dynamic project name using pet + 6-digit suffix
  dynamic_project_name = "${random_pet.project_name.id}-${random_id.project_suffix.hex}"

  # Project name with account suffix for uniqueness
  project_name_with_account = "${local.dynamic_project_name}-${substr(data.aws_caller_identity.current.account_id, -4, 4)}"

  # Get project profile ID from the project profiles module (using dynamic profile)
  project_profile_id = module.project_profiles.dynamic_profile_id

  common_tags = {
    DomainName  = var.domain_name
    Environment = var.environment
    Owner       = var.owner
    CreatedBy   = "terraform-mvp-example"
  }
}

# Create the SageMaker Unified Studio domain with integrated IAM role
module "domain" {
  source = "../.."

  domain_name                  = var.domain_name
  description                  = var.domain_description
  create_domain_execution_role = true

  tags = local.common_tags
}

# Create random pet name for project with 6-digit suffix
resource "random_pet" "project_name" {
  length    = 2
  separator = "-"
}

resource "random_id" "project_suffix" {
  byte_length = 3 # 3 bytes = 6 hex digits
}

# Create S3 bucket for tooling environment using community module
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

module "s3_bucket_tooling" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-s3-bucket.git?ref=v4.2.2"

  bucket                   = "${local.dynamic_project_name}-tooling-${random_id.bucket_suffix.hex}"
  control_object_ownership = true
  object_ownership         = "BucketOwnerEnforced"
  block_public_acls        = true
  block_public_policy      = true
  ignore_public_acls       = true
  restrict_public_buckets  = true

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning = {
    enabled = true
  }

  tags = merge(local.common_tags, {
    Purpose = "SageMaker Unified Studio Tooling Environment"
  })
}

# Enable Blueprint Configurations with integrated SageMaker roles
module "blueprints" {
  source = "../../modules/blueprints"

  domain_id              = module.domain.domain_id
  domain_name            = var.domain_name
  create_sagemaker_roles = true
  s3_bucket_name         = module.s3_bucket_tooling.s3_bucket_id
  vpc_id                 = data.aws_vpc.default.id
  subnet_ids             = data.aws_subnets.default.ids

  # Enable available blueprints for testing
  enable_tooling             = true  # Required for other environments
  enable_data_lake           = var.enable_data_lake
  enable_redshift_serverless = var.enable_redshift_serverless
  enable_sagemaker           = var.enable_sagemaker
  enable_custom_aws_service  = var.enable_custom_aws_service

  tags = local.common_tags

  depends_on = [module.domain]
}

# Lake Formation configuration for SageMaker Unified Studio
# MOVED EARLIER: Grant Lake Formation admin permissions BEFORE project creation
# This ensures roles have proper permissions when environments are auto-created
resource "aws_lakeformation_data_lake_settings" "main" {
  admins = [
    module.domain.domain_execution_role_arn,
    module.blueprints.sagemaker_manage_access_role_arn,
    module.blueprints.sagemaker_provisioning_role_arn
  ]

  # Ensure this is created after the domain and roles exist, but before project creation
  depends_on = [
    module.domain,
    module.blueprints
  ]
}

# Wait for Lake Formation settings to propagate before proceeding
# This ensures permissions are fully active before environments are created
resource "time_sleep" "lakeformation_propagation" {
  depends_on = [aws_lakeformation_data_lake_settings.main]

  create_duration = "30s"
}

# Create project profiles
module "project_profiles" {
  source = "../../modules/project-profiles"

  domain_id = module.domain.domain_id

  # Enable dynamic profile creation for the MVP
  enable_dynamic_profile = true
  dynamic_profile_name   = "${var.domain_name}-mvp-profile"

  # Enable the blueprints we want in the profile
  enable_data_lake           = var.enable_data_lake
  enable_redshift_serverless = var.enable_redshift_serverless
  enable_sagemaker           = var.enable_sagemaker

  # Pass blueprint IDs from the blueprints module (dynamic IDs)
  tooling_id             = module.blueprints.tooling_id
  data_lake_id           = module.blueprints.data_lake_id
  redshift_serverless_id = module.blueprints.redshift_serverless_id
  ml_experiments_id      = module.blueprints.sagemaker_id

  tags = local.common_tags

  # UPDATED: Now depends on Lake Formation settings being configured first
  depends_on = [
    module.blueprints,
    aws_lakeformation_data_lake_settings.main,
    time_sleep.lakeformation_propagation
  ]
}


# Create project using the project module
module "project" {
  source = "../../modules/project"

  domain_id           = module.domain.domain_id
  project_name        = local.project_name_with_account
  project_description = var.project_description
  # Only pass project_profile_id if it's available and valid
  project_profile_id = module.project_profiles.dynamic_profile_id != null && module.project_profiles.dynamic_profile_id != "" ? module.project_profiles.dynamic_profile_id : null

  # UPDATED: Ensure Lake Formation permissions are set before project creation
  depends_on = [
    module.blueprints,
    module.project_profiles,
    aws_lakeformation_data_lake_settings.main,
    time_sleep.lakeformation_propagation
  ]
}

# Add explicit timeouts for destroy operations
resource "time_sleep" "destroy_wait" {
  depends_on = [module.project]
  
  destroy_duration = "30m" # 30 minute timeout for destroy operations
}
