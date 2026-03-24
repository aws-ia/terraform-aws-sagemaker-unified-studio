# Multi-Account SageMaker Unified Studio Domain Example
# This example creates a domain with organization-wide resource sharing
# Equivalent to deploying cloudformation/domain/create_domain.yaml with organization setup

terraform {
  required_version = ">= 1.5"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.37.0"
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
      Example     = "multi-account-domain"
    }
  }
}

# Local values for resource naming and tagging
locals {
  common_tags = {
    DomainName     = var.domain_name
    Environment    = var.environment
    Owner          = var.owner
    CreatedBy      = "terraform-multi-account-domain-example"
    OrganizationId = var.organization_id
  }
}

# Step 1: Discover organization accounts (replaces fetch_accounts.yml)
module "organization" {
  source = "../../modules/organization"
  
  organization_id            = var.organization_id
  exclude_management_account = var.exclude_management_account
  specific_account_ids       = var.specific_account_ids
  
  tags = local.common_tags
}

# Step 2: Create IAM roles required for the domain
module "iam_roles" {
  source = "../../modules/iam"
  
  domain_name = var.domain_name
  
  # Create required roles
  create_domain_execution_role = true
  create_sagemaker_roles      = true
  
  tags = local.common_tags
}

# Step 3: Create the SageMaker Unified Studio domain
module "domain" {
  source = "../../modules/domain"
  
  domain_name                = var.domain_name
  description               = var.domain_description
  domain_execution_role_arn = module.iam_roles.domain_execution_role_arn
  
  tags = local.common_tags
  
  # Ensure IAM roles are created before domain
  depends_on = [module.iam_roles]
}

# Step 4: Set up resource sharing (replaces create_resource_share.yaml)
module "resource_sharing" {
  source = "../../modules/resource-sharing"
  
  # Domain information
  domain_id   = module.domain.domain_id
  domain_arn  = module.domain.domain_arn
  domain_name = module.domain.domain_name
  
  # Account sharing configuration
  account_ids                = module.organization.accounts_for_sharing
  enable_resource_sharing    = var.enable_resource_sharing
  exclude_current_account    = var.exclude_current_account
  allow_external_principals  = var.allow_external_principals
  auto_accept_shares        = var.auto_accept_shares
  
  tags = local.common_tags
  
  # Ensure domain is created before sharing
  depends_on = [module.domain]
}
