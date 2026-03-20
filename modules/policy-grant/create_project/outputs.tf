#####################################################################################
# Create Project Policy Grant Module Outputs
#####################################################################################

output "grant_ids" {
  description = "Map of principal keys to their policy grant IDs."
  value       = { for k, v in awscc_datazone_policy_grant.this : k => v.grant_id }
}

output "domain_id" {
  description = "The domain ID."
  value       = var.domain_id
}

output "domain_unit_id" {
  description = "The domain unit ID derived from the project profiles."
  value       = local.domain_unit_id
}
