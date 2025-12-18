# Domain Module Outputs
# These outputs match the CloudFormation template outputs and provide essential domain information

output "domain_id" {
  description = "ID of the SageMaker Unified Studio domain"
  value       = aws_datazone_domain.main.id
}

output "domain_arn" {
  description = "ARN of the SageMaker Unified Studio domain"
  value       = aws_datazone_domain.main.arn
}

output "domain_name" {
  description = "Name of the SageMaker Unified Studio domain"
  value       = aws_datazone_domain.main.name
}

output "domain_url" {
  description = "Portal URL of the SageMaker Unified Studio domain"
  value       = aws_datazone_domain.main.portal_url
}

output "domain_root_unit_id" {
  description = "Actual root domain unit ID (not domain ID)"
  value       = data.awscc_datazone_domain.main.root_domain_unit_id
}

output "account_id" {
  description = "AWS Account ID where the domain is created"
  value       = data.aws_caller_identity.current.account_id
}

output "region" {
  description = "AWS Region where the domain is created"
  value       = data.aws_region.current.id
}

output "domain_execution_role_arn" {
  description = "ARN of the domain execution role (created or existing)"
  value       = var.create_domain_execution_role ? aws_iam_role.domain_execution[0].arn : var.domain_execution_role_arn
}

output "domain_execution_role_name" {
  description = "Name of the domain execution role"
  value       = var.create_domain_execution_role ? aws_iam_role.domain_execution[0].name : null
}
