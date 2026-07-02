#####################################################################################
# Singular Project Profile Module Outputs
#####################################################################################

output "project_profile_id" {
  description = "The ID of the created project profile"
  value       = awscc_datazone_project_profile.this.project_profile_id

  # Force consumers (e.g. project module) to wait until the project profile
  # resource has been fully applied. Without this, downstream resources or
  # data sources that reference the profile can race the apply and fail
  # with "AWS Data Source Not Found" or unknown-value plan errors.
  depends_on = [awscc_datazone_project_profile.this]
}

output "name" {
  description = "The name of the project profile"
  value       = var.name
}

output "blueprint_count" {
  description = "Number of blueprints in this project profile"
  value       = length(var.blueprints)
}

output "blueprint_names" {
  description = "List of blueprint names included in this project profile"
  value       = keys(var.blueprints)
}
