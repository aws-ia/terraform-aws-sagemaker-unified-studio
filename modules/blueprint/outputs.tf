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

output "manage_access_role_arn" {
  description = "ARN of the ManageAccess role (created, existing, or user-provided)"
  value       = local.manage_access_role_arn
}

output "manage_access_role_created" {
  description = "Whether the ManageAccess role was created by this module"
  value       = var.manage_access_role_arn == null && !local.manage_access_role_exists
}

output "provisioning_role_arn" {
  description = "ARN of the Provisioning role (created, existing, or user-provided)"
  value       = local.provisioning_role_arn
}

output "provisioning_role_created" {
  description = "Whether the Provisioning role was created by this module"
  value       = var.provisioning_role_arn == null && !local.provisioning_role_exists
}

output "lake_formation_configured" {
  description = "Whether Lake Formation data lake settings have been configured"
  value       = var.configure_lake_formation
}

output "enabled_regions" {
  description = "List of AWS regions where the blueprint is enabled"
  value       = local.enabled_regions
}
