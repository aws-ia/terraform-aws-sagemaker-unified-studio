# Outputs for the SageMaker Unified Studio Cross-Account Example.
#
# Outputs that depend on modules not currently invoked by main.tf are
# commented out. Uncomment when wiring up the corresponding modules.

#####################################################################################
# Domain Outputs (from module.domain)
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

output "tooling_blueprint_id" {
  description = "ID of the Tooling blueprint (created by the domain module)"
  value       = module.domain.tooling_blueprint_id
}

#####################################################################################
# IAM Role Outputs (from module.domain)
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
# Cross-Account Module Outputs
#####################################################################################

output "cross_account_resource_share_arn" {
  description = "ARN of the RAM resource share created in the source account"
  value       = module.cross_account.resource_share_arn
}

output "cross_account_destination_account_id" {
  description = "AWS account ID that received the domain share (destination)"
  value       = module.cross_account.destination_account_id
}

output "cross_account_manage_access_role_arn" {
  description = "ARN of the ManageAccess role bootstrapped in the destination account"
  value       = module.cross_account.manage_access_role_arn
}

output "cross_account_provisioning_role_arn" {
  description = "ARN of the Provisioning role bootstrapped in the destination account"
  value       = module.cross_account.provisioning_role_arn
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
  description = "Source AWS account ID where the domain is created"
  value       = data.aws_caller_identity.current.account_id
}

output "region" {
  description = "Source AWS region where the domain is created"
  value       = data.aws_region.current.region
}

#####################################################################################
# Disabled outputs — modules below are not invoked in this example.
# Uncomment along with the corresponding module blocks in main.tf.
#####################################################################################

# output "blueprint_ids" {
#   description = "Map of blueprint logical names to their resolved blueprint IDs"
#   value       = { for key, bp in module.blueprints : key => bp.blueprint_id }
# }
#
# output "blueprint_names" {
#   description = "Map of blueprint logical names to their blueprint names"
#   value       = { for key, bp in module.blueprints : key => bp.blueprint_name }
# }
#
# output "project_profile_ids" {
#   description = "List of all enabled project profile IDs"
#   value = concat(
#     [for p in module.all_capabilities_project_profile : p.project_profile_id],
#     [for p in module.sql_analytics_project_profile : p.project_profile_id],
#     [for p in module.generative_ai_project_profile : p.project_profile_id],
#   )
# }
#
# output "project_id" {
#   description = "ID of the created project"
#   value       = length(module.project) > 0 ? module.project[0].project_id : null
# }
#
# output "project_name" {
#   description = "Name of the created project"
#   value       = length(module.project) > 0 ? module.project[0].project_name : null
# }
#
# output "project_url" {
#   description = "URL to access the project in SageMaker Unified Studio"
#   value       = length(module.project) > 0 ? module.project[0].project_url : null
# }
