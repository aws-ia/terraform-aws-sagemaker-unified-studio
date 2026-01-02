# Outputs for SageMaker Unified Studio MVP Example
# This combines outputs from both basic-domain and single-account-project examples

# Domain Information
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

# Blueprint Information
output "enabled_blueprints" {
  description = "List of enabled blueprint identifiers"
  value       = module.blueprints.enabled_blueprints
}

output "blueprint_count" {
  description = "Number of enabled blueprints"
  value       = module.blueprints.blueprint_count
}

output "blueprint_ids" {
  description = "Map of blueprint identifiers"
  value = {
    tooling            = module.blueprints.tooling_id
    data_lake          = module.blueprints.data_lake_id
    data_warehouse     = module.blueprints.redshift_serverless_id
    sagemaker          = module.blueprints.sagemaker_id
    custom_aws_service = module.blueprints.custom_aws_service_id
  }
}

# Project Information
output "project_id" {
  description = "ID of the created project"
  value       = module.project.project_id
}

output "project_name" {
  description = "Name of the created project"
  value       = module.project.project_name
}

output "project_status" {
  description = "Status of the created project"
  value       = "ACTIVE" # awscc provider doesn't expose status, assume active if created
}

output "project_url" {
  description = "URL to access the project"
  value       = module.project.project_url
}

# Infrastructure Information
output "s3_bucket_name" {
  description = "Name of the S3 bucket created for tooling environment"
  value       = module.s3_bucket_tooling.s3_bucket_id
}

output "vpc_id" {
  description = "VPC ID used for SageMaker environments"
  value       = data.aws_vpc.default.id
}

output "subnet_ids" {
  description = "Subnet IDs used for SageMaker environments"
  value       = data.aws_subnets.default.ids
}

# IAM Role Information
output "domain_execution_role_arn" {
  description = "ARN of the domain execution role"
  value       = module.domain.domain_execution_role_arn
}

output "domain_execution_role_name" {
  description = "Name of the domain execution role"
  value       = module.domain.domain_execution_role_name
}

output "sagemaker_manage_access_role_arn" {
  description = "ARN of the SageMaker manage access role"
  value       = module.blueprints.sagemaker_manage_access_role_arn
}

output "sagemaker_provisioning_role_arn" {
  description = "ARN of the SageMaker provisioning role"
  value       = module.blueprints.sagemaker_provisioning_role_arn
}

# Account and Region Information
output "account_id" {
  description = "AWS account ID where resources are created"
  value       = data.aws_caller_identity.current.account_id
}

output "region" {
  description = "AWS region where resources are created"
  value       = data.aws_region.current.id
}

# Next Steps Information
output "next_steps" {
  description = "Information about next steps after deployment"
  value = {
    domain_access      = "Visit ${module.domain.domain_url} to access your SageMaker Unified Studio domain"
    project_access     = "Navigate to Projects section and find '${module.project.project_name}' (ID: ${module.project.project_id})"
    blueprints_enabled = "Enabled ${module.blueprints.blueprint_count} blueprints: ${join(", ", module.blueprints.enabled_blueprints)}"
    manual_steps       = "Project profiles and user memberships must be configured manually via AWS Console or CLI (not yet available in Terraform)"
  }
}

# Validation Information
output "validation_commands" {
  description = "AWS CLI commands to validate the deployment"
  value = {
    check_domain    = "aws datazone get-domain --identifier ${module.domain.domain_id}"
    list_blueprints = "aws datazone list-environment-blueprint-configurations --domain-identifier ${module.domain.domain_id}"
    get_project     = "aws datazone get-project --identifier ${module.project.project_id} --domain-identifier ${module.domain.domain_id}"
    list_projects   = "aws datazone list-projects --domain-identifier ${module.domain.domain_id}"
  }
}

# Terraform Provider Limitations Notice
output "terraform_limitations" {
  description = "Current limitations of the Terraform AWS provider for DataZone"
  value = {
    missing_resources = [
      "aws_datazone_project_profile - Project profiles must be created via AWS Console/CLI",
      "aws_datazone_project_membership - User memberships must be managed via AWS Console/CLI"
    ]
    workaround = "Use AWS CLI commands to complete project setup after Terraform deployment"
    cli_examples = {
      create_project_profile = "aws datazone create-project-profile --domain-identifier ${module.domain.domain_id} --name 'Basic Analytics' --environment-configurations file://profile-config.json"
      add_project_member     = "aws datazone create-project-membership --domain-identifier ${module.domain.domain_id} --project-identifier ${module.project.project_id} --member UserIdentifier=user@example.com --designation PROJECT_OWNER"
    }
  }
}