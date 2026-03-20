#####################################################################################
# Domain Unit Policy Grant Module
# Grants principals (domain units, users, or groups) the ability to create
# projects from specified project profiles within a domain unit.
#####################################################################################

locals {
  # When all_users is true, only create the all-users grant -- skip everything else.
  grants = var.all_users ? {
    "user.all_users" = {
      principal = {
        user = {
          all_users_grant_filter = jsonencode({})
        }
      }
    }
  } : merge(
    # User principals
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
  entity_identifier = var.domain_unit_id
  policy_type       = "CREATE_PROJECT_FROM_PROJECT_PROFILE"

  detail = {
    create_project_from_project_profile = {
      include_child_domain_units = var.include_child_domain_units
      project_profiles           = var.project_profile_ids
    }
  }

  principal = each.value.principal
}
