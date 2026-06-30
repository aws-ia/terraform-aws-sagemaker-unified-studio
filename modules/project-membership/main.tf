#####################################################################################
# Project Membership Module
# Adds project members from two principal sets: project_owners (PROJECT_OWNER) and
# project_contributors (PROJECT_CONTRIBUTOR). Each set accepts any combination of
# SSO users, SSO groups, IAM users, and IAM roles, and a membership is created for
# each entry via for_each.
#
# Member type mapping:
# - SSO_USER / IAM_USER: mapped to user_identifier.
# - SSO_GROUP / IAM_ROLE: mapped to group_identifier.
#
# Validations:
# - Variable-level: per-sub-type identifier format (see variables.tf).
# - SSO_USER / SSO_GROUP: existence of the corresponding DataZone user/group profile
#   in the domain is verified at plan time via data sources + lifecycle preconditions.
#####################################################################################

locals {
  # Flatten each principal set into [{ key, member_type, identifier, designation }]
  # tuples so the membership resource can be driven by a single for_each.
  owner_members = concat(
    [for u in var.project_owners.sso_users : { member_type = "SSO_USER", identifier = u, designation = "PROJECT_OWNER" }],
    [for g in var.project_owners.sso_groups : { member_type = "SSO_GROUP", identifier = g, designation = "PROJECT_OWNER" }],
    [for a in var.project_owners.iam_users : { member_type = "IAM_USER", identifier = a, designation = "PROJECT_OWNER" }],
    [for a in var.project_owners.iam_roles : { member_type = "IAM_ROLE", identifier = a, designation = "PROJECT_OWNER" }],
  )

  contributor_members = concat(
    [for u in var.project_contributors.sso_users : { member_type = "SSO_USER", identifier = u, designation = "PROJECT_CONTRIBUTOR" }],
    [for g in var.project_contributors.sso_groups : { member_type = "SSO_GROUP", identifier = g, designation = "PROJECT_CONTRIBUTOR" }],
    [for a in var.project_contributors.iam_users : { member_type = "IAM_USER", identifier = a, designation = "PROJECT_CONTRIBUTOR" }],
    [for a in var.project_contributors.iam_roles : { member_type = "IAM_ROLE", identifier = a, designation = "PROJECT_CONTRIBUTOR" }],
  )

  # Keyed map of every member across both sets. The key encodes the designation,
  # member type, and identifier so it is stable and unique.
  members = {
    for m in concat(local.owner_members, local.contributor_members) :
    "${m.designation}.${m.member_type}.${m.identifier}" => m
  }

  # Subsets that require a DataZone profile existence check.
  sso_user_members  = { for k, m in local.members : k => m if m.member_type == "SSO_USER" }
  sso_group_members = { for k, m in local.members : k => m if m.member_type == "SSO_GROUP" }
}

# Look up each SSO user profile in the domain. Fails the plan if the user has not
# been registered in the domain.
data "awscc_datazone_user_profile" "sso_user" {
  for_each = local.sso_user_members
  id       = "${var.domain_id}|${each.value.identifier}"
}

# Look up each group profile in the domain. Fails the plan if the group has not
# been registered in the domain.
data "awscc_datazone_group_profile" "sso_group" {
  for_each = local.sso_group_members
  id       = "${var.domain_id}|${each.value.identifier}"
}

resource "awscc_datazone_project_membership" "this" {
  for_each = local.members

  domain_identifier  = var.domain_id
  project_identifier = var.project_id
  designation        = each.value.designation

  member = {
    user_identifier  = each.value.member_type == "SSO_USER" || each.value.member_type == "IAM_USER" ? each.value.identifier : null
    group_identifier = each.value.member_type == "SSO_GROUP" || each.value.member_type == "IAM_ROLE" ? each.value.identifier : null
  }

  lifecycle {
    precondition {
      condition     = each.value.member_type != "SSO_USER" || contains(keys(data.awscc_datazone_user_profile.sso_user), each.key)
      error_message = "SSO user '${each.value.identifier}' is not registered in domain '${var.domain_id}'. Create an aws_datazone_user_profile for this user before adding them to a project."
    }

    precondition {
      condition     = each.value.member_type != "SSO_GROUP" || contains(keys(data.awscc_datazone_group_profile.sso_group), each.key)
      error_message = "SSO group '${each.value.identifier}' does not have a group profile in domain '${var.domain_id}'. Create an awscc_datazone_group_profile for this group before adding it to a project."
    }
  }
}
