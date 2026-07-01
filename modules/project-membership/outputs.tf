#####################################################################################
# Project Membership Module Outputs
#####################################################################################

output "members" {
  description = <<-EOT
    The final list of project members created by this module, after dedup and
    owner precedence. Each entry includes the principal identifier, its member
    type (SSO_USER, SSO_GROUP, IAM_USER, IAM_ROLE), the assigned designation
    (PROJECT_OWNER or PROJECT_CONTRIBUTOR), and the resulting membership id.
  EOT
  value = [
    for k, m in local.members : {
      identifier    = m.identifier
      member_type   = m.member_type
      designation   = m.designation
      membership_id = awscc_datazone_project_membership.this[k].id
    }
  ]
}