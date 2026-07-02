#####################################################################################
# Default Project Profile Module Outputs
#####################################################################################

output "project_profile_id" {
  description = "The ID of the created default project profile"
  value       = awscc_datazone_project_profile.this.project_profile_id

  # Force consumers (e.g. project module) to wait until the project profile
  # resource has been fully applied. Without this, downstream resources or
  # data sources that reference the profile can race the apply and fail
  # with "AWS Data Source Not Found" or unknown-value plan errors.
  depends_on = [awscc_datazone_project_profile.this]
}

# Blueprint IDs for the three managed blueprints. Useful for downstream modules
# that need to reference the blueprint configurations created here.

output "tooling_lite_blueprint_id" {
  description = "Environment blueprint ID for ToolingLite"
  value       = data.aws_datazone_environment_blueprint.tooling_lite.id
}

output "s3_bucket_blueprint_id" {
  description = "Environment blueprint ID for S3Bucket"
  value       = data.aws_datazone_environment_blueprint.s3_bucket.id
}

output "s3_table_catalog_blueprint_id" {
  description = "Environment blueprint ID for S3TableCatalog"
  value       = data.aws_datazone_environment_blueprint.s3_table_catalog.id
}