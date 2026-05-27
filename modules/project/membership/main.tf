#####################################################################################
# Project Membership Module
# Adds a single user (SSO_USER, SSO_GROUP, or IAM principal) to a project with a
# specified role.
#
# Validations:
# - Variable-level: member_type, project_role, identifier format (see variables.tf).
# - SSO_USER / SSO_GROUP: existence of the corresponding DataZone user/group profile
#   in the domain is verified at plan time via data sources + lifecycle preconditions.
#####################################################################################

# Look up the SSO user profile in the domain when member_type = SSO_USER.
# Fails the plan if the user has not been registered in the domain.
data "awscc_datazone_user_profile" "sso_user" {
  count = var.member_type == "SSO_USER" ? 1 : 0
  id    = "${var.domain_id}|${var.identifier}"
}

# Look up the group profile in the domain when member_type = SSO_GROUP.
# Fails the plan if the group has not been registered in the domain.
data "awscc_datazone_group_profile" "sso_group" {
  count = var.member_type == "SSO_GROUP" ? 1 : 0
  id    = "${var.domain_id}|${var.identifier}"
}

resource "awscc_datazone_project_membership" "this" {
  domain_identifier  = var.domain_id
  project_identifier = var.project_id
  designation        = var.project_role

  member = {
    user_identifier  = var.member_type == "SSO_USER" ? var.identifier : null
    group_identifier = var.member_type == "SSO_GROUP" || var.member_type == "IAM" ? var.identifier : null
  }

  lifecycle {
    precondition {
      condition     = var.member_type != "SSO_USER" || length(data.awscc_datazone_user_profile.sso_user) == 1
      error_message = "SSO user '${var.identifier}' is not registered in domain '${var.domain_id}'. Create an aws_datazone_user_profile for this user before adding them to a project."
    }

    precondition {
      condition     = var.member_type != "SSO_GROUP" || length(data.awscc_datazone_group_profile.sso_group) == 1
      error_message = "SSO group '${var.identifier}' does not have a group profile in domain '${var.domain_id}'. Create an awscc_datazone_group_profile for this group before adding it to a project."
    }
  }
}
