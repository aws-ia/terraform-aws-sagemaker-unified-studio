#####################################################################################
# Cross-Account Module Outputs
#####################################################################################

output "domain_id" {
  description = "ID of the SageMaker Unified Studio domain that was shared"
  value       = data.aws_datazone_domain.main.id
}

output "source_account_id" {
  description = "AWS account ID that owns the domain (source)"
  value       = data.aws_caller_identity.current.account_id
}

output "destination_account_id" {
  description = "AWS account ID that received the domain share (destination)"
  value       = data.aws_caller_identity.alternate.account_id
}

output "resource_share_arn" {
  description = "ARN of the RAM resource share created in the source account"
  value       = aws_ram_resource_share.domain_share.arn
}

output "resource_share_name" {
  description = "Name of the RAM resource share created in the source account"
  value       = aws_ram_resource_share.domain_share.name
}

output "manage_access_role_arn" {
  description = "ARN of the ManageAccess role created in the destination account by the bootstrap submodule"
  value       = module.bootstrap.manage_access_role_arn
}

output "provisioning_role_arn" {
  description = "ARN of the Provisioning role created in the destination account by the bootstrap submodule"
  value       = module.bootstrap.provisioning_role_arn
}
