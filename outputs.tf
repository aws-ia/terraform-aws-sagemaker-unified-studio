# Domain Module Outputs
# These outputs match the CloudFormation template outputs and provide essential domain information

output "domain_id" {
  description = "ID of the SageMaker Unified Studio domain"
  value       = aws_datazone_domain.main.id

  # Bind this output to the Tooling blueprint. Any consumer of domain_id
  # (e.g. project profile modules) transitively depends on the Tooling blueprint,
  # so on destroy those consumers are torn down BEFORE Tooling is disabled.
  depends_on = [module.tooling_blueprint]
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
  value       = data.aws_datazone_domain.main.root_domain_unit_id

  # Bind this output to the Tooling blueprint so consumers that build on the root
  # domain unit (e.g. project profiles) are destroyed BEFORE Tooling is disabled.
  depends_on = [module.tooling_blueprint]
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
  value       = local.domain_execution_role_arn
}

output "domain_execution_role_name" {
  description = "Name of the domain execution role"
  value       = local.default_domain_execution_role_name
}

output "domain_service_role_arn" {
  description = "ARN of the domain service role (created or existing)"
  value       = local.domain_service_role_arn
}

output "domain_service_role_name" {
  description = "Name of the domain service role"
  value       = local.default_domain_service_role_name
}

output "domain_execution_role_created" {
  description = "Whether the domain execution role was created by this module (false if it already existed)"
  value       = local.create_domain_execution_role && length(data.aws_iam_roles.domain_execution_role.arns) == 0
}

output "domain_service_role_created" {
  description = "Whether the domain service role was created by this module (false if it already existed)"
  value       = local.create_domain_service_role && length(data.aws_iam_roles.domain_service_role.arns) == 0
}

# --- Blueprint Role Outputs ---
output "manage_access_role_arn" {
  description = "ARN of the manage access role (created or provided). Pass to blueprint modules."
  value       = local.manage_access_role_arn
}

output "provisioning_role_arn" {
  description = "ARN of the provisioning role (created or provided). Pass to blueprint modules."
  value       = local.provisioning_role_arn
}

# --- Tooling Blueprint Outputs ---
output "tooling_blueprint_id" {
  description = "ID of the Tooling environment blueprint"
  value       = module.tooling_blueprint.blueprint_id
}

output "s3_bucket_name" {
  description = "S3 bucket name used by the Tooling blueprint (created or provided)"
  value       = local.s3_bucket_name
}

output "query_execution_role_arn" {
  description = "ARN of the query execution role (created or provided). Used by the Tooling blueprint."
  value       = local.query_execution_role_arn
}
