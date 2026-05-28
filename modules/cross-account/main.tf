#####################################################################################
# Cross-Account Domain Association Module
#
# Shares a SageMaker Unified Studio domain from a source AWS account with a
# destination AWS account via AWS RAM, accepts the share in the destination
# (when not using AWS Organizations), and bootstraps the destination account
# with the IAM roles required to provision blueprints.
#
# Required providers (passed by caller via `providers` map):
#   aws.source      — domain-owning account
#   aws.destination — associated account
#####################################################################################

######################################
# Data Sources
######################################

data "aws_region" "current" {
  provider = aws.source
}

data "aws_caller_identity" "current" {
  provider = aws.source
}

data "aws_region" "alternate" {
  provider = aws.destination
}

data "aws_caller_identity" "alternate" {
  provider = aws.destination
}

data "aws_datazone_domain" "main" {
  provider = aws.source
  id       = var.domain_id
}

######################################
# Region consistency check
######################################

# DataZone cross-account associations require both accounts to operate in the
# same AWS region. Fail the plan early with a clear message if the source and
# destination provider regions don't match.
resource "terraform_data" "region_consistency_validation" {
  lifecycle {
    precondition {
      condition     = data.aws_region.current.id == data.aws_region.alternate.id
      error_message = "Source provider region (${data.aws_region.current.id}) must match destination provider region (${data.aws_region.alternate.id}). Configure both aws.source and aws.destination providers with the same region."
    }
  }
}

######################################
# RAM Resource Share (source account)
######################################

resource "aws_ram_resource_share" "domain_share" {
  provider                  = aws.source
  name                      = "DataZone-${data.aws_datazone_domain.main.name}-${data.aws_datazone_domain.main.id}"
  allow_external_principals = true
  permission_arns = [
    "arn:aws:ram::aws:permission/AWSRAMPermissionsAmazonDatazoneDomainExtendedServiceAccess"
  ]

  depends_on = [terraform_data.region_consistency_validation]
}

resource "aws_ram_resource_association" "domain_share_domain_association" {
  provider           = aws.source
  resource_arn       = data.aws_datazone_domain.main.arn
  resource_share_arn = aws_ram_resource_share.domain_share.arn
}

resource "aws_ram_principal_association" "domain_share_principal_association" {
  provider           = aws.source
  principal          = data.aws_caller_identity.alternate.account_id
  resource_share_arn = aws_ram_resource_share.domain_share.arn
}

######################################
# RAM Share Acceptance (destination account)
######################################

# When both accounts are in the same AWS Organization, RAM shares are
# auto-accepted and this resource is skipped.
resource "aws_ram_resource_share_accepter" "receiver_accept" {
  count     = var.using_organizations ? 0 : 1
  provider  = aws.destination
  share_arn = aws_ram_resource_share.domain_share.arn

  depends_on = [
    aws_ram_resource_share.domain_share,
    aws_ram_resource_association.domain_share_domain_association,
    aws_ram_principal_association.domain_share_principal_association,
  ]
}

######################################
# Destination-side IAM bootstrap
######################################

# Create the SageMakerProvisioning and ManageAccess IAM roles in the
# destination account so blueprint configurations can reference them when
# the domain provisions environments cross-account. Lake Formation settings
# are also configured on the destination account.
#
# The bootstrap submodule only consumes the default `aws` provider; we map
# our `aws.destination` alias to it so all created resources land in the
# associated account.
module "bootstrap" {
  source = "../blueprint/bootstrap"

  providers = {
    aws = aws.destination
  }

  domain_id                = data.aws_datazone_domain.main.id
  domain_account_id        = data.aws_caller_identity.current.account_id
  configure_lake_formation = true

  depends_on = [
    aws_ram_resource_share.domain_share,
    aws_ram_resource_association.domain_share_domain_association,
    aws_ram_principal_association.domain_share_principal_association,
    aws_ram_resource_share_accepter.receiver_accept,
  ]
}
