# SageMaker Unified Studio MVP Example
# This example combines domain creation and project setup in a single configuration
# Equivalent to deploying both basic-domain and single-account-project examples together

terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.15.0"
    }
    awscc = {
      source  = "hashicorp/awscc"
      version = ">= 1.50.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9"
    }
  }
}

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

# Create IAM roles required for the domain
module "iam_roles" {
  source = "../../modules/iam"

  domain_name = var.domain_name

  # Create required roles (matches CloudFormation behavior)
  create_domain_execution_role = true
  create_sagemaker_roles       = true

  tags = local.common_tags
}

# Wait for IAM role propagation before creating domain
# IAM roles need time to propagate globally before they can be assumed by AWS services
resource "time_sleep" "wait_for_iam_propagation" {
  create_duration = "30s"
  
  # This resource will be created after the IAM role ARN is available
  triggers = {
    domain_execution_role_arn = module.iam_roles.domain_execution_role_arn
  }
  
  depends_on = [module.iam_roles]
}

# Create the SageMaker Unified Studio domain
module "domain" {
  source = "../../modules/domain"

  domain_name               = var.domain_name
  description               = var.domain_description
  domain_execution_role_arn = module.iam_roles.domain_execution_role_arn
  enable_sso                = var.enable_sso

  tags = local.common_tags

  # Ensure IAM roles are created and propagated before domain
  depends_on = [time_sleep.wait_for_iam_propagation]
}

# Create random pet name for project with 6-digit suffix
resource "random_pet" "project_name" {
  length = 2
  separator = "-"
}

resource "random_id" "project_suffix" {
  byte_length = 3  # 3 bytes = 6 hex digits
}

# Create S3 bucket for tooling environment
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "tooling" {
  bucket = "${local.dynamic_project_name}-tooling-${random_id.bucket_suffix.hex}"

  tags = merge(local.common_tags, {
    Purpose = "SageMaker Unified Studio Tooling Environment"
  })
}

resource "aws_s3_bucket_versioning" "tooling" {
  bucket = aws_s3_bucket.tooling.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tooling" {
  bucket = aws_s3_bucket.tooling.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Enable Blueprint Configurations
module "blueprints" {
  source = "../../modules/blueprints"

  domain_id              = module.domain.domain_id
  manage_access_role_arn = module.iam_roles.sagemaker_manage_access_role_arn
  provisioning_role_arn  = module.iam_roles.sagemaker_provisioning_role_arn
  s3_bucket_name         = aws_s3_bucket.tooling.bucket
  vpc_id                 = data.aws_vpc.default.id
  subnet_ids             = data.aws_subnets.default.ids

  # Enable available blueprints for testing
  enable_data_lake                = var.enable_data_lake
  enable_redshift_serverless      = var.enable_redshift_serverless
  enable_sagemaker                = var.enable_sagemaker
  enable_custom_aws_service       = var.enable_custom_aws_service

  tags = local.common_tags

  depends_on = [module.domain]
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

  # Pass blueprint IDs from the blueprints module
  tooling_id             = "4k186sfh08eqxc"  # Tooling blueprint ID
  data_lake_id           = "ciw5fxhc6v6rio" # Data Lake blueprint ID
  redshift_serverless_id = "dlyaabb17hano0" # Redshift Serverless blueprint ID
  ml_experiments_id      = "c9gx7j7bemrv0w" # SageMaker blueprint ID

  tags = local.common_tags

  depends_on = [module.blueprints]
}


# Create project using the project module
module "project" {
  source = "../../modules/project"
  
  domain_id            = module.domain.domain_id
  project_name         = local.project_name_with_account
  project_description  = var.project_description
  # Only pass project_profile_id if it's available and valid
  project_profile_id   = module.project_profiles.dynamic_profile_id != null && module.project_profiles.dynamic_profile_id != "" ? module.project_profiles.dynamic_profile_id : null
  
  depends_on = [
    module.blueprints,
    module.project_profiles
  ]
}

# Lake Formation configuration for SageMaker Unified Studio
resource "aws_lakeformation_data_lake_settings" "main" {
  admins = [
    module.iam_roles.domain_execution_role_arn,
    module.iam_roles.sagemaker_manage_access_role_arn,
    module.iam_roles.sagemaker_provisioning_role_arn
  ]
}
