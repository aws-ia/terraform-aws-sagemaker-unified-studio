# Project Module Outputs

# Project Details
output "project_id" {
  description = "ID of the created project"
  value       = awscc_datazone_project.admin_project.project_id
}

output "project_name" {
  description = "Name of the created project"
  value       = awscc_datazone_project.admin_project.name
}

output "project_description" {
  description = "Description of the created project"
  value       = awscc_datazone_project.admin_project.description
}

# Project URLs and Access
output "project_url" {
  description = "URL to access the project in SageMaker Unified Studio"
  value       = "https://${var.domain_id}.datazone.${data.aws_region.current.region}.on.aws/projects/${awscc_datazone_project.admin_project.project_id}"
}

# Configuration Details
output "domain_id" {
  description = "Domain ID where project is created"
  value       = var.domain_id
}

output "region" {
  description = "AWS region where project is created"
  value       = data.aws_region.current.region
}

output "account_id" {
  description = "AWS account ID where project is created"
  value       = data.aws_caller_identity.current.account_id
}

# Admin role ARN
# DataZone auto-creates a project execution role per project with the naming
# convention: datazone_usr_role_<project_id>_<domain_id_without_dzd_prefix>
# The ARN below is constructed deterministically from the project + domain IDs.
output "admin_role_arn" {
  description = "ARN of the DataZone-managed admin/user execution role for this project"
  value = format(
    "arn:aws:iam::%s:role/datazone_usr_role_%s_%s",
    data.aws_caller_identity.current.account_id,
    awscc_datazone_project.admin_project.project_id,
    replace(var.domain_id, "/^dzd[-_]/", ""),
  )
}

output "admin_role_name" {
  description = "Name of the DataZone-managed admin/user execution role for this project"
  value = format(
    "datazone_usr_role_%s_%s",
    awscc_datazone_project.admin_project.project_id,
    replace(var.domain_id, "/^dzd[-_]/", ""),
  )
}