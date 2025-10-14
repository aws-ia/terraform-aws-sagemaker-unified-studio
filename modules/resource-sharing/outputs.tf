# Resource Sharing Module Outputs
# These outputs provide information about the created resource shares

# Resource share information
output "resource_share_arn" {
  description = "ARN of the created resource share"
  value       = local.sharing_enabled ? aws_ram_resource_share.domain_share[0].arn : null
}

output "resource_share_id" {
  description = "ID of the created resource share"
  value       = local.sharing_enabled ? aws_ram_resource_share.domain_share[0].id : null
}

output "resource_share_name" {
  description = "Name of the created resource share"
  value       = local.sharing_enabled ? aws_ram_resource_share.domain_share[0].name : null
}

output "resource_share_status" {
  description = "Status of the resource share"
  value       = local.sharing_enabled ? aws_ram_resource_share.domain_share[0].status : null
}

# Sharing configuration
output "sharing_enabled" {
  description = "Whether resource sharing is enabled"
  value       = local.sharing_enabled
}

output "shared_with_accounts" {
  description = "List of account IDs that the domain is shared with"
  value       = local.filtered_account_ids
}

output "shared_with_accounts_count" {
  description = "Number of accounts the domain is shared with"
  value       = length(local.filtered_account_ids)
}

# Association information
output "resource_association_arn" {
  description = "ARN of the resource association"
  value       = local.sharing_enabled ? aws_ram_resource_association.domain_association[0].associated_entity : null
}

output "principal_associations" {
  description = "Map of principal associations (account ID -> association ARN)"
  value = local.sharing_enabled ? {
    for account_id, association in aws_ram_principal_association.account_associations :
    account_id => association.associated_entity
  } : {}
}

# Permission information
output "permission_arn" {
  description = "ARN of the DataZone domain permission used"
  value       = local.sharing_enabled ? data.aws_ram_permission.datazone_domain_permission[0].arn : null
}

output "permission_name" {
  description = "Name of the DataZone domain permission used"
  value       = local.sharing_enabled ? data.aws_ram_permission.datazone_domain_permission[0].name : null
}

# Summary information
output "sharing_summary" {
  description = "Summary of resource sharing configuration"
  value = {
    enabled                   = local.sharing_enabled
    resource_share_name      = local.resource_share_name
    domain_shared           = var.domain_name
    accounts_count          = length(local.filtered_account_ids)
    allow_external          = var.allow_external_principals
    auto_accept            = var.auto_accept_shares
    exclude_current_account = var.exclude_current_account
  }
}
