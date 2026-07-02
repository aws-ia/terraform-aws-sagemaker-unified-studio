#####################################################################################
# Singular Blueprint Module Outputs
#####################################################################################

output "manage_access_role_arn" {
  description = "ARN of the ManageAccess role (created, existing, or user-provided)"
  value       = var.create_manage_access_role ? aws_iam_role.sagemaker_manage_access[0].arn : ""

  # Bind this output to the role's policy attachments. Any consumer of the ARN
  # (e.g. blueprint configurations, the domain) transitively depends on the
  # attachments, so on destroy the consumer is torn down BEFORE the policies are
  # detached — the role keeps its permissions until it is itself destroyed.
  depends_on = [
    aws_iam_role_policy_attachment.sagemaker_manage_access,
    aws_iam_role_policy_attachment.sagemaker_manage_access_custom,
    aws_iam_role_policy_attachment.glue_manage_access,
    aws_iam_role_policy_attachment.redshift_manage_access,
  ]
}

output "create_manage_access_role" {
  description = "Whether the ManageAccess role was created by this module"
  value       = var.create_manage_access_role
}

output "provisioning_role_arn" {
  description = "ARN of the Provisioning role (created, existing, or user-provided)"
  value       = var.create_provisioning_role ? aws_iam_role.sagemaker_provisioning[0].arn : ""

  # Bind this output to the role's policy attachment. Any consumer of the ARN
  # (e.g. blueprint configurations, the domain) transitively depends on the
  # attachment, so on destroy the consumer is torn down BEFORE the policy is
  # detached — the role keeps its permissions until it is itself destroyed.
  depends_on = [
    aws_iam_role_policy_attachment.sagemaker_provisioning,
  ]
}

output "create_provisioning_role" {
  description = "Whether the Provisioning role was created by this module"
  value       = var.create_provisioning_role
}
