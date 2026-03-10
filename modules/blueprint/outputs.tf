#####################################################################################
# Singular Blueprint Module Outputs
#####################################################################################

output "blueprint_id" {
  description = "The environment blueprint ID (resolved from blueprint_name)"
  value       = data.aws_datazone_environment_blueprint.this.id
}

output "blueprint_name" {
  description = "The blueprint name that was configured"
  value       = var.blueprint_name
}

output "entity_id" {
  description = "Entity identifier for policy grants (account_id:blueprint_id)"
  value       = "${local.account_id}:${data.aws_datazone_environment_blueprint.this.id}"
}


output "provisioning_role_source" {
  description = "How the provisioning role was resolved: 'variable' if passed via var, 'data_lookup' if found by name"
  value       = var.provisioning_role_arn != null ? "variable" : "data_lookup"
}

output "manage_access_role_source" {
  description = "How the manage access role was resolved: 'variable' if passed via var, 'data_lookup' if found by name"
  value       = var.manage_access_role_arn != null ? "variable" : "data_lookup"
}

output "enabled_regions" {
  description = "List of AWS regions where the blueprint is enabled"
  value       = local.enabled_regions
}
