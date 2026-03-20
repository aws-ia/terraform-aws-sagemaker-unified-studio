#####################################################################################
# Domain Unit Policy Grant Module Outputs
#####################################################################################

output "grant_ids" {
  description = "Map of principal keys to their policy grant IDs."
  value       = { for k, v in awscc_datazone_policy_grant.this : k => v.grant_id }
}
