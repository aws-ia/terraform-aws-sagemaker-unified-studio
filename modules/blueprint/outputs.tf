#####################################################################################
# Singular Blueprint Configuration Module Outputs
#####################################################################################

output "blueprint_id" {
  description = "The environment blueprint ID"
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
  description = "ARN of the ManageAccess role (created or provided)"
  value       = local.manage_access_role_arn
}

output "provisioning_role_arn" {
  description = "ARN of the Provisioning role (created or provided)"
  value       = local.provisioning_role_arn
}
