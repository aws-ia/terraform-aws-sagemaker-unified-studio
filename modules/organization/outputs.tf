# Organization Module Outputs
# These outputs provide organization and account information for resource sharing

# Account information
output "current_account_id" {
  description = "Current AWS account ID"
  value       = local.current_account_id
}

output "current_region" {
  description = "Current AWS region"
  value       = local.current_region
}

# Organization information
output "organization_enabled" {
  description = "Whether AWS Organizations integration is enabled"
  value       = local.organization_enabled
}

output "organization_id" {
  description = "AWS Organizations ID (if enabled)"
  value       = local.organization_enabled ? data.aws_organizations_organization.current[0].id : null
}

output "organization_arn" {
  description = "AWS Organizations ARN (if enabled)"
  value       = local.organization_enabled ? data.aws_organizations_organization.current[0].arn : null
}

output "organization_master_account_id" {
  description = "AWS Organizations master account ID (if enabled)"
  value       = local.organization_enabled ? data.aws_organizations_organization.current[0].master_account_id : null
}

# Account lists (equivalent to CloudFormation Lambda outputs)
output "all_account_ids" {
  description = "All account IDs in the organization (equivalent to Lambda function output)"
  value       = local.active_account_ids
}

output "accounts_for_sharing" {
  description = "Filtered account IDs for resource sharing (equivalent to CloudFormation AccountsForResourceShare)"
  value       = local.accounts_for_sharing
}

output "accounts_for_sharing_count" {
  description = "Number of accounts that will receive resource shares"
  value       = length(local.accounts_for_sharing)
}

# Detailed account information
output "active_accounts" {
  description = "Detailed information about active accounts in the organization"
  value       = local.active_accounts
  sensitive   = true
}

# Comma-separated format (matching CloudFormation output format)
output "account_ids_comma_separated" {
  description = "Account IDs as comma-separated string (matches CloudFormation format)"
  value       = join(",", local.accounts_for_sharing)
}

# Configuration summary
output "configuration_summary" {
  description = "Summary of organization configuration"
  value = {
    organization_enabled        = local.organization_enabled
    exclude_management_account = var.exclude_management_account
    using_specific_accounts    = var.specific_account_ids != null
    total_accounts_found       = length(local.active_account_ids)
    accounts_for_sharing       = length(local.accounts_for_sharing)
  }
}
