# Outputs for SageMaker Unified Studio Quick-Setup Example
# Exposes domain, blueprint, and profile outputs from the modular architecture

#####################################################################################
# Domain Outputs
#####################################################################################

output "domain_id" {
  description = "ID of the created SageMaker Unified Studio domain"
  value       = module.domain.domain_id
}

output "domain_arn" {
  description = "ARN of the created SageMaker Unified Studio domain"
  value       = module.domain.domain_arn
}

output "domain_name" {
  description = "Name of the created SageMaker Unified Studio domain"
  value       = module.domain.domain_name
}

output "domain_url" {
  description = "Portal URL for accessing the SageMaker Unified Studio domain"
  value       = module.domain.domain_url
}

output "domain_root_unit_id" {
  description = "Root domain unit ID of the domain"
  value       = module.domain.domain_root_unit_id
}

# Tooling blueprint — created automatically by the domain module
output "tooling_blueprint_id" {
  description = "ID of the Tooling blueprint (created by the domain module)"
  value       = module.domain.tooling_blueprint_id
}

#####################################################################################
# Blueprint Outputs
#####################################################################################

output "blueprint_ids" {
  description = "Map of blueprint logical names to their resolved blueprint IDs"
  value       = { for key, bp in module.blueprints : key => bp.blueprint_id }
}

output "blueprint_names" {
  description = "Map of blueprint logical names to their blueprint names"
  value       = { for key, bp in module.blueprints : key => bp.blueprint_name }
}

#####################################################################################
# Project Profile Outputs
#####################################################################################

output "project_profile_ids" {
  description = "List of all enabled project profile IDs"
  value = concat(
    [module.default_project_profile.project_profile_id]
  )
}

#####################################################################################
# Project Outputs
#####################################################################################

output "project_id" {
  description = "ID of the created project"
  value       =  module.default_project.project_id
}

output "project_name" {
  description = "Name of the created project"
  value       =  module.default_project.project_name
}

output "project_url" {
  description = "URL to access the project in SageMaker Unified Studio"
  value       =  module.default_project.project_url
}

#####################################################################################
# IAM Role Outputs
#####################################################################################

output "domain_execution_role_arn" {
  description = "ARN of the domain execution role"
  value       = module.domain.domain_execution_role_arn
}

output "domain_service_role_arn" {
  description = "ARN of the domain service role"
  value       = module.domain.domain_service_role_arn
}

output "manage_access_role_arn" {
  description = "ARN of the manage access role (from domain module)"
  value       = module.domain.manage_access_role_arn
}

output "provisioning_role_arn" {
  description = "ARN of the provisioning role (from domain module)"
  value       = module.domain.provisioning_role_arn
}

#####################################################################################
# Infrastructure Outputs
#####################################################################################

output "s3_bucket_name" {
  description = "S3 bucket name used by the domain"
  value       = module.domain.s3_bucket_name
}

output "vpc_id" {
  description = "VPC ID used for blueprint configurations"
  value       = local.vpc_id
}

output "subnet_ids" {
  description = "Subnet IDs used for blueprint configurations"
  value       = local.subnet_ids
}

output "account_id" {
  description = "AWS account ID where resources are created"
  value       = data.aws_caller_identity.current.account_id
}

output "region" {
  description = "AWS region where resources are created"
  value       = data.aws_region.current.id
}
