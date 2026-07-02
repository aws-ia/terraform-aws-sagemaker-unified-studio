# Project Module Outputs

# Project Details
output "project_id" {
  description = "ID of the created project"
  value       = awscc_datazone_project.main.project_id
}

output "project_name" {
  description = "Name of the created project"
  value       = awscc_datazone_project.main.name
}

output "project_description" {
  description = "Description of the created project"
  value       = awscc_datazone_project.main.description
}

output "project_profile_id" {
  description = "Project profile ID used for this project"
  value       = awscc_datazone_project.main.project_profile_id
}

# Project URLs and Access
output "project_url" {
  description = "URL to access the project in SageMaker Unified Studio"
  value       = "https://${var.domain_id}.datazone.${data.aws_region.current.id}.on.aws/projects/${awscc_datazone_project.main.project_id}"
}

# Configuration Details
output "domain_id" {
  description = "Domain ID where project is created"
  value       = var.domain_id
}

output "region" {
  description = "AWS region where project is created"
  value       = data.aws_region.current.id
}

output "account_id" {
  description = "AWS account ID where project is created"
  value       = data.aws_caller_identity.current.account_id
}

# User Parameters
output "user_parameters" {
  description = "User parameters configured for the project"
  value       = var.user_parameters
  sensitive   = false
}

# Next Steps Information
output "next_steps" {
  description = "Information about next steps after project creation"
  value = {
    access_url = "Visit https://${var.domain_id}.datazone.${data.aws_region.current.id}.on.aws/projects/${awscc_datazone_project.main.project_id} to access your project"
    project_id = "Use project ID '${awscc_datazone_project.main.project_id}' for further configuration"
  }
}
