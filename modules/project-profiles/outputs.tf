# Project Profile Module Outputs

# Profile IDs - Only return values for resources that actually exist
output "basic_analytics_profile_id" {
  description = "ID of the basic analytics project profile"
  value       = null  # Terraform resource is commented out, only dynamic profiles are supported
}

output "ml_focused_profile_id" {
  description = "ID of the ML-focused project profile"
  value       = null  # Terraform resource is commented out, only dynamic profiles are supported
}

output "all_capabilities_profile_id" {
  description = "ID of the all capabilities project profile"
  value       = null  # Terraform resource is commented out, only dynamic profiles are supported
}

output "dynamic_profile_id" {
  description = "ID of the dynamic project profile"
  value       = (length(awscc_datazone_project_profile.dynamic_project_profile) > 0) ? awscc_datazone_project_profile.dynamic_project_profile[0].project_profile_id : null
}

# Profile Names - Only return values for resources that actually exist
output "basic_analytics_profile_name" {
  description = "Name of the basic analytics project profile"
  value       = null  # Terraform resource is commented out, only dynamic profiles are supported
}

output "ml_focused_profile_name" {
  description = "Name of the ML-focused project profile"
  value       = null  # Terraform resource is commented out, only dynamic profiles are supported
}

output "all_capabilities_profile_name" {
  description = "Name of the all capabilities project profile"
  value       = null  # Terraform resource is commented out, only dynamic profiles are supported
}

output "dynamic_profile_name" {
  description = "Name of the dynamic project profile"
  value       = var.enable_dynamic_profile ? var.dynamic_profile_name : null
}

# Summary outputs
output "created_profiles" {
  description = "List of created project profile names"
  value = compact([
    var.enable_dynamic_profile ? var.dynamic_profile_name : ""
  ])
}

output "profile_count" {
  description = "Number of created project profiles"
  value = var.enable_dynamic_profile ? 1 : 0
}

# Available profile IDs for project creation - Only return dynamic profile
output "available_profile_ids" {
  description = "Map of available project profile IDs"
  value = {
    basic_analytics   = null  # Not supported via Terraform resources
    ml_focused       = null  # Not supported via Terraform resources
    all_capabilities = null  # Not supported via Terraform resources
    dynamic          = (length(awscc_datazone_project_profile.dynamic_project_profile) > 0) ? awscc_datazone_project_profile.dynamic_project_profile[0].project_profile_id : null
  }
}

# Configuration details
output "domain_id" {
  description = "Domain ID where profiles are created"
  value       = var.domain_id
}

output "region" {
  description = "AWS region where profiles are created"
  value       = data.aws_region.current.id  # Use .id instead of deprecated .name
}

output "account_id" {
  description = "AWS account ID where profiles are created"
  value       = data.aws_caller_identity.current.account_id
}
