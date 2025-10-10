# IAM Module Outputs
# These outputs provide the ARNs of created or existing IAM roles for use by other modules

# Domain Execution Role
output "domain_execution_role_arn" {
  description = "ARN of the domain execution role (created or existing)"
  value       = var.create_domain_execution_role ? aws_iam_role.domain_execution[0].arn : var.existing_domain_execution_role_arn
}

output "domain_execution_role_name" {
  description = "Name of the domain execution role"
  value       = var.create_domain_execution_role ? aws_iam_role.domain_execution[0].name : null
}

# SageMaker Manage Access Role
output "sagemaker_manage_access_role_arn" {
  description = "ARN of the SageMaker manage access role (created or existing)"
  value       = var.create_sagemaker_roles ? aws_iam_role.sagemaker_manage_access[0].arn : var.existing_sagemaker_manage_access_role_arn
}

output "sagemaker_manage_access_role_name" {
  description = "Name of the SageMaker manage access role"
  value       = var.create_sagemaker_roles ? aws_iam_role.sagemaker_manage_access[0].name : null
}

# SageMaker Provisioning Role
output "sagemaker_provisioning_role_arn" {
  description = "ARN of the SageMaker provisioning role (created or existing)"
  value       = var.create_sagemaker_roles ? aws_iam_role.sagemaker_provisioning[0].arn : var.existing_sagemaker_provisioning_role_arn
}

output "sagemaker_provisioning_role_name" {
  description = "Name of the SageMaker provisioning role"
  value       = var.create_sagemaker_roles ? aws_iam_role.sagemaker_provisioning[0].name : null
}

# Consolidated outputs for easy reference
output "all_role_arns" {
  description = "Map of all IAM role ARNs (created or existing)"
  value = {
    domain_execution_role_arn        = var.create_domain_execution_role ? aws_iam_role.domain_execution[0].arn : var.existing_domain_execution_role_arn
    sagemaker_manage_access_role_arn = var.create_sagemaker_roles ? aws_iam_role.sagemaker_manage_access[0].arn : var.existing_sagemaker_manage_access_role_arn
    sagemaker_provisioning_role_arn  = var.create_sagemaker_roles ? aws_iam_role.sagemaker_provisioning[0].arn : var.existing_sagemaker_provisioning_role_arn
  }
}

output "created_roles" {
  description = "List of IAM roles created by this module"
  value = compact([
    var.create_domain_execution_role ? aws_iam_role.domain_execution[0].name : null,
    var.create_sagemaker_roles ? aws_iam_role.sagemaker_manage_access[0].name : null,
    var.create_sagemaker_roles ? aws_iam_role.sagemaker_provisioning[0].name : null
  ])
}
