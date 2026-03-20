#####################################################################################
# Domain Unit Policy Grant Module
# Grants principals (domain units, users, or groups) the ability to create
# projects from specified project profiles within a domain unit.
#
# The domain_unit_id is derived from the project profiles via data source
# lookup — all profiles must belong to the same domain unit.
#####################################################################################

# Look up each project profile to extract domain_unit_id
data "awscc_datazone_project_profile" "this" {
  for_each = toset(var.project_profile_ids)
  id       = "${var.domain_id}|${each.value}"
}

locals {
  # Collect unique domain unit IDs across all profiles
  domain_unit_ids = distinct([for pp in data.awscc_datazone_project_profile.this : pp.domain_unit_id])

  # Resolved value (validated by precondition below)
  domain_unit_id = local.domain_unit_ids[0]

  # When all_users is true, only create the all-users grant — skip everything else.
  grants = var.all_users ? {
    "user.all_users" = {
      principal = {
        user = {
          all_users_grant_filter = jsonencode({})
        }
      }
    }
  } : merge(
    # User principals — individual users
    {
      for u in var.user_principals : "user.${u}" => {
        principal = {
          user = {
            user_identifier = u
          }
        }
      }
    },
    # Group principals
    {
      for g in var.group_principals : "group.${g}" => {
        principal = {
          group = {
            group_identifier = g
          }
        }
      }
    }
  )
}

resource "awscc_datazone_policy_grant" "this" {
  for_each = local.grants

  domain_identifier = var.domain_id
  entity_type       = "DOMAIN_UNIT"
  entity_identifier = local.domain_unit_id
  policy_type       = "CREATE_PROJECT_FROM_PROJECT_PROFILE"

  detail = {
    create_project_from_project_profile = {
      include_child_domain_units = var.include_child_domain_units
      project_profiles           = var.project_profile_ids
    }
  }

  principal = each.value.principal

  lifecycle {
    precondition {
      condition     = length(local.domain_unit_ids) == 1
      error_message = "All project profiles must belong to the same domain unit. Found domain units: ${join(", ", local.domain_unit_ids)}"
    }
  }
}
