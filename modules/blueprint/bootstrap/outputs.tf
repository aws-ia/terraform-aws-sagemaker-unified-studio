#####################################################################################
# Singular Blueprint Module Outputs
#####################################################################################

output "manage_access_role_arn" {
  description = "ARN of the ManageAccess role (created, existing, or user-provided)"
  value       = var.create_manage_access_role ? aws_iam_role.sagemaker_manage_access[0].arn : ""
}

output "create_manage_access_role" {
  description = "Whether the ManageAccess role was created by this module"
  value       = var.create_manage_access_role
}

output "provisioning_role_arn" {
  description = "ARN of the Provisioning role (created, existing, or user-provided)"
  value       = var.create_provisioning_role ? aws_iam_role.sagemaker_provisioning[0].arn : ""
}

output "create_provisioning_role" {
  description = "Whether the Provisioning role was created by this module"
  value       = var.create_provisioning_role
}

output "lake_formation_configured" {
  description = "Whether Lake Formation data lake settings have been configured"
  value       = var.configure_lake_formation
}
