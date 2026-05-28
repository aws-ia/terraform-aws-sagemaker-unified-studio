#####################################################################################
# Admin Project Module
# Creates the singleton admin project for a SageMaker Unified Studio domain.
#
# Preconditions enforced before the project is created:
# 1. The Tooling blueprint must be configured (enabled) for the domain in the
#    current region. Verified via awscc_datazone_environment_blueprint_configuration.
# 2. A CREATE_PROJECT policy grant must exist on the root domain unit. Verified
#    via the policy_grant_dependencies variable, which forces an implicit
#    dependency on the upstream grant resource.
#####################################################################################

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_datazone_domain" "main" {
  id = var.domain_id
}

# Resolve the Tooling blueprint ID for this domain so we can read its config.
data "aws_datazone_environment_blueprint" "tooling" {
  domain_id = var.domain_id
  name      = "Tooling"
  managed   = true
}

# Verify the Tooling blueprint is configured (enabled with roles + regions) for
# this domain. The data source returns the configuration if it exists; an
# unconfigured blueprint surfaces as an empty enabled_regions list.
data "awscc_datazone_environment_blueprint_configuration" "tooling" {
  id = "${var.domain_id}|${data.aws_datazone_environment_blueprint.tooling.id}"
}


resource "awscc_datazone_project" "admin_project" {
  domain_identifier = var.domain_id
  domain_unit_id    = data.aws_datazone_domain.main.root_domain_unit_id
  name              = "admin-project-${data.aws_caller_identity.current.account_id}"
  project_category  = "ADMIN"

  lifecycle {
    precondition {
      condition     = contains(data.awscc_datazone_environment_blueprint_configuration.tooling.enabled_regions, data.aws_region.current.region)
      error_message = "Tooling blueprint is not configured for domain '${var.domain_id}' in region '${data.aws_region.current.region}'. Enable the Tooling blueprint via the blueprint module before creating the admin project."
    }
  }
}
