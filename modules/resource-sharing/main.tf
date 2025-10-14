# Resource Sharing Module
# This module replaces the CloudFormation template cloudformation/domain/create_resource_share.yaml
# It creates AWS RAM resource shares for SageMaker Unified Studio domain

# Get current AWS account and region information
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  # Resource sharing configuration
  sharing_enabled = var.enable_resource_sharing && length(var.account_ids) > 0
  
  # Resource share name (matches CloudFormation naming pattern)
  resource_share_name = var.resource_share_name != null ? var.resource_share_name : "DataZone-${var.domain_name}-${var.domain_id}"
  
  # Tags for resource sharing
  common_tags = merge(var.tags, {
    ManagedBy = "Terraform"
    Module    = "sagemaker-unified-studio-resource-sharing"
    DomainId  = var.domain_id
  })
  
  # Account validation
  valid_account_ids = [
    for account_id in var.account_ids : account_id
    if can(regex("^[0-9]{12}$", account_id))
  ]
  
  # Remove current account if specified
  filtered_account_ids = var.exclude_current_account ? [
    for account_id in local.valid_account_ids : account_id
    if account_id != data.aws_caller_identity.current.account_id
  ] : local.valid_account_ids
}

# AWS RAM Resource Share (equivalent to CloudFormation AWS::RAM::ResourceShare)
resource "aws_ram_resource_share" "domain_share" {
  count = local.sharing_enabled ? 1 : 0
  
  name                      = local.resource_share_name
  description               = "Resource share for SageMaker Unified Studio domain ${var.domain_name}"
  allow_external_principals = var.allow_external_principals
  
  tags = local.common_tags
}

# Resource Association - Associate the DataZone domain with the resource share
resource "aws_ram_resource_association" "domain_association" {
  count = local.sharing_enabled ? 1 : 0
  
  resource_arn       = var.domain_arn
  resource_share_arn = aws_ram_resource_share.domain_share[0].arn
}

# Principal Associations - Share with each account (replaces CloudFormation ForEach loop)
resource "aws_ram_principal_association" "account_associations" {
  for_each = local.sharing_enabled ? toset(local.filtered_account_ids) : toset([])
  
  principal          = each.value
  resource_share_arn = aws_ram_resource_share.domain_share[0].arn
  
  depends_on = [aws_ram_resource_association.domain_association]
}

# Permission Association - Use the same permission as CloudFormation
resource "aws_ram_resource_share_accepter" "domain_share_accepter" {
  count = local.sharing_enabled && var.auto_accept_shares ? 1 : 0
  
  share_arn = aws_ram_resource_share.domain_share[0].arn
  
  depends_on = [
    aws_ram_resource_association.domain_association,
    aws_ram_principal_association.account_associations
  ]
}

# Data source to get the permission ARN (matches CloudFormation permission)
data "aws_ram_permission" "datazone_domain_permission" {
  count = local.sharing_enabled ? 1 : 0
  
  name                = "AWSRAMPermissionsAmazonDatazoneDomainExtendedServiceAccess"
  permission_type     = "RESOURCE_BASED"
  resource_type       = "datazone:Domain"
}

# Associate the permission with the resource share
resource "aws_ram_permission_association" "domain_permission" {
  count = local.sharing_enabled ? 1 : 0
  
  permission_arn     = data.aws_ram_permission.datazone_domain_permission[0].arn
  resource_share_arn = aws_ram_resource_share.domain_share[0].arn
  
  depends_on = [aws_ram_resource_association.domain_association]
}

# Validation resource
resource "terraform_data" "sharing_validation" {
  count = local.sharing_enabled ? 1 : 0
  
  lifecycle {
    precondition {
      condition     = length(local.filtered_account_ids) > 0
      error_message = "No valid account IDs provided for resource sharing."
    }
    
    precondition {
      condition     = var.domain_arn != null && var.domain_arn != ""
      error_message = "Domain ARN is required for resource sharing."
    }
    
    precondition {
      condition     = var.domain_id != null && var.domain_id != ""
      error_message = "Domain ID is required for resource sharing."
    }
  }
}
