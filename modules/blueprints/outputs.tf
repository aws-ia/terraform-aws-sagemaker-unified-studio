# Blueprint Configuration Module Outputs

# Blueprint IDs (always available when enabled)
output "tooling_id" {
  description = "ID of the Tooling blueprint configuration (required for other environments)"
  value       = var.enable_tooling ? aws_datazone_environment_blueprint_configuration.tooling[0].environment_blueprint_id : null
}

output "data_lake_id" {
  description = "ID of the Lakehouse Catalog blueprint configuration (V2)"
  value       = var.enable_data_lake ? aws_datazone_environment_blueprint_configuration.data_lake[0].environment_blueprint_id : null
}

output "redshift_serverless_id" {
  description = "ID of the Redshift Serverless blueprint configuration (V2)"
  value       = var.enable_redshift_serverless ? aws_datazone_environment_blueprint_configuration.redshift_serverless[0].environment_blueprint_id : null
}

output "sagemaker_id" {
  description = "ID of the ML Experiments blueprint configuration (V2)"
  value       = var.enable_sagemaker ? aws_datazone_environment_blueprint_configuration.sagemaker[0].environment_blueprint_id : null
}

output "custom_aws_service_id" {
  description = "ID of the Custom AWS Service blueprint configuration"
  value       = var.enable_custom_aws_service ? aws_datazone_environment_blueprint_configuration.custom_aws_service[0].environment_blueprint_id : null
}

# Policy Grant Entity Identifiers (account_id:blueprint_id format)
output "tooling_entity_id" {
  description = "Entity identifier for Tooling blueprint policy grants (account_id:blueprint_id)"
  value       = var.enable_tooling ? "${data.aws_caller_identity.current.account_id}:${aws_datazone_environment_blueprint_configuration.tooling[0].environment_blueprint_id}" : null
}

output "data_lake_entity_id" {
  description = "Entity identifier for Data Lake blueprint policy grants (account_id:blueprint_id)"
  value       = var.enable_data_lake ? "${data.aws_caller_identity.current.account_id}:${aws_datazone_environment_blueprint_configuration.data_lake[0].environment_blueprint_id}" : null
}

output "redshift_serverless_entity_id" {
  description = "Entity identifier for Redshift Serverless blueprint policy grants (account_id:blueprint_id)"
  value       = var.enable_redshift_serverless ? "${data.aws_caller_identity.current.account_id}:${aws_datazone_environment_blueprint_configuration.redshift_serverless[0].environment_blueprint_id}" : null
}

output "sagemaker_entity_id" {
  description = "Entity identifier for SageMaker blueprint policy grants (account_id:blueprint_id)"
  value       = var.enable_sagemaker ? "${data.aws_caller_identity.current.account_id}:${aws_datazone_environment_blueprint_configuration.sagemaker[0].environment_blueprint_id}" : null
}

# Summary outputs
output "enabled_blueprints" {
  description = "List of enabled blueprint identifiers"
  value = compact([
    var.enable_tooling ? "Tooling" : "",
    var.enable_data_lake ? "LakehouseCatalog" : "",
    var.enable_redshift_serverless ? "RedshiftServerless" : "",
    var.enable_sagemaker ? "MLExperiments" : "",
    var.enable_custom_aws_service ? "CustomAwsService" : ""
  ])
}

output "blueprint_count" {
  description = "Number of enabled blueprints"
  value = length(compact([
    var.enable_tooling ? "Tooling" : "",
    var.enable_data_lake ? "LakehouseCatalog" : "",
    var.enable_redshift_serverless ? "RedshiftServerless" : "",
    var.enable_sagemaker ? "MLExperiments" : "",
    var.enable_custom_aws_service ? "CustomAwsService" : ""
  ]))
}

# Configuration details
output "domain_id" {
  description = "Domain ID where blueprints are configured"
  value       = var.domain_id
}

output "region" {
  description = "AWS region where blueprints are configured"
  value       = data.aws_region.current.id
}

output "account_id" {
  description = "AWS account ID where blueprints are configured"
  value       = data.aws_caller_identity.current.account_id
}

# Policy grant status
output "policy_grants_enabled" {
  description = "Whether policy grants have been configured for domain unit access"
  value       = var.domain_id != null
}

# SageMaker Role Outputs
output "sagemaker_manage_access_role_arn" {
  description = "ARN of the SageMaker manage access role (created or existing)"
  value       = local.manage_access_role_arn
}

output "sagemaker_manage_access_role_created" {
  description = "Whether the SageMaker manage access role was created by this module (false if it already existed or was user-provided)"
  value       = var.manage_access_role_arn == null && !local.manage_access_role_exists
}

output "sagemaker_provisioning_role_arn" {
  description = "ARN of the SageMaker provisioning role (created or existing)"
  value       = local.provisioning_role_arn
}

output "sagemaker_provisioning_role_created" {
  description = "Whether the SageMaker provisioning role was created by this module (false if it already existed or was user-provided)"
  value       = var.provisioning_role_arn == null && !local.provisioning_role_exists
}

# Lake Formation Configuration Outputs
output "lake_formation_configured" {
  description = "Whether Lake Formation data lake settings have been configured"
  value       = var.configure_lake_formation
}

output "lake_formation_admins" {
  description = "List of IAM role ARNs granted Lake Formation admin permissions"
  value = var.configure_lake_formation ? compact([
    var.domain_execution_role_arn,
    local.manage_access_role_arn,
    local.provisioning_role_arn
  ]) : []
}
