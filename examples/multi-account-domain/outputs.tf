# Outputs for Multi-Account Domain Example
# These outputs provide essential information about the created domain, organization, and resource sharing

# Domain Information
output "domain_id" {
  description = "ID of the created SageMaker Unified Studio domain"
  value       = module.domain.domain_id
}

output "domain_arn" {
  description = "ARN of the created SageMaker Unified Studio domain"
  value       = module.domain.domain_arn
}

output "domain_name" {
  description = "Name of the created SageMaker Unified Studio domain"
  value       = module.domain.domain_name
}

output "domain_url" {
  description = "Portal URL for accessing the SageMaker Unified Studio domain"
  value       = module.domain.domain_url
}

output "domain_status" {
  description = "Current status of the domain"
  value       = module.domain.domain_status
}

# Organization Information
output "organization_id" {
  description = "AWS Organizations ID"
  value       = module.organization.organization_id
}

output "organization_enabled" {
  description = "Whether AWS Organizations integration is enabled"
  value       = module.organization.organization_enabled
}

output "total_accounts_found" {
  description = "Total number of active accounts found in the organization"
  value       = length(module.organization.all_account_ids)
}

output "accounts_for_sharing" {
  description = "List of account IDs that the domain is shared with"
  value       = module.organization.accounts_for_sharing
}

output "accounts_for_sharing_count" {
  description = "Number of accounts the domain is shared with"
  value       = module.organization.accounts_for_sharing_count
}

# Resource Sharing Information
output "resource_sharing_enabled" {
  description = "Whether resource sharing is enabled"
  value       = module.resource_sharing.sharing_enabled
}

output "resource_share_arn" {
  description = "ARN of the created resource share"
  value       = module.resource_sharing.resource_share_arn
}

output "resource_share_name" {
  description = "Name of the created resource share"
  value       = module.resource_sharing.resource_share_name
}

output "resource_share_status" {
  description = "Status of the resource share"
  value       = module.resource_sharing.resource_share_status
}

# IAM Role Information
output "iam_roles" {
  description = "ARNs of all created IAM roles"
  value       = module.iam_roles.all_role_arns
  sensitive   = true
}

output "created_iam_roles" {
  description = "Names of IAM roles created by this deployment"
  value       = module.iam_roles.created_roles
}

# Deployment Information
output "account_id" {
  description = "AWS Account ID where the domain was created"
  value       = module.domain.account_id
}

output "region" {
  description = "AWS Region where the domain was created"
  value       = module.domain.region
}

# Configuration Summary
output "deployment_summary" {
  description = "Summary of the multi-account deployment"
  value = {
    domain_name              = module.domain.domain_name
    domain_id               = module.domain.domain_id
    organization_enabled    = module.organization.organization_enabled
    resource_sharing_enabled = module.resource_sharing.sharing_enabled
    accounts_shared_with    = module.organization.accounts_for_sharing_count
    sso_enabled            = var.enable_sso
    environment            = var.environment
  }
}

# Next Steps Information
output "next_steps" {
  description = "Next steps after domain creation"
  value = {
    access_url = "Visit ${module.domain.domain_url} to access your SageMaker Unified Studio domain"
    domain_id  = "Use domain ID '${module.domain.domain_id}' for further configuration"
    sso_setup  = var.enable_sso ? "SSO is enabled - configure users in AWS IAM Identity Center" : "SSO is disabled - configure IAM users/roles as needed"
    shared_accounts = "Domain is shared with ${module.organization.accounts_for_sharing_count} accounts in your organization"
    resource_share = module.resource_sharing.sharing_enabled ? "Resource share '${module.resource_sharing.resource_share_name}' created successfully" : "Resource sharing is disabled"
  }
}
