# Organization Module
# This module replaces the Lambda function in cloudformation/domain/fetch_accounts.yml
# It discovers AWS Organization accounts for domain resource sharing

# Get current AWS account and region information
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Get AWS Organizations information
data "aws_organizations_organization" "current" {
  count = var.organization_id != null ? 1 : 0
}

# Get all accounts in the organization
data "aws_organizations_organizational_units" "root" {
  count     = var.organization_id != null ? 1 : 0
  parent_id = data.aws_organizations_organization.current[0].roots[0].id
}

# Local processing to filter accounts (equivalent to Lambda logic)
locals {
  # Current account information
  current_account_id = data.aws_caller_identity.current.account_id
  current_region     = data.aws_region.current.id
  
  # Organization accounts (when organization is enabled)
  organization_enabled = var.organization_id != null
  
  # Get all accounts from organization (replaces Lambda list_org_accounts function)
  all_org_accounts = local.organization_enabled ? [
    for account in data.aws_organizations_organization.current[0].accounts : {
      id     = account.id
      name   = account.name
      email  = account.email
      status = account.status
    }
  ] : []
  
  # Filter active accounts only (replaces Lambda filtering logic)
  active_accounts = [
    for account in local.all_org_accounts : account
    if account.status == "ACTIVE"
  ]
  
  # Account IDs for resource sharing (equivalent to Lambda output)
  active_account_ids = [for account in local.active_accounts : account.id]
  
  # Filtered account IDs based on configuration
  filtered_account_ids = var.exclude_management_account ? [
    for account_id in local.active_account_ids : account_id
    if account_id != local.current_account_id
  ] : local.active_account_ids
  
  # Final account list for resource sharing
  accounts_for_sharing = var.specific_account_ids != null ? var.specific_account_ids : local.filtered_account_ids
  
  # Validation
  has_accounts_to_share = length(local.accounts_for_sharing) > 0
}

# Validation checks
resource "terraform_data" "organization_validation" {
  count = var.organization_id != null ? 1 : 0
  
  lifecycle {
    precondition {
      condition     = local.organization_enabled
      error_message = "Organization ID is provided but organization data could not be retrieved. Ensure AWS Organizations is enabled and accessible."
    }
    
    precondition {
      condition     = local.has_accounts_to_share
      error_message = "No accounts found for resource sharing. Check organization configuration and account filters."
    }
  }
}
