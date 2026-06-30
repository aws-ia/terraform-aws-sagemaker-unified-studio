<!-- BEGIN_TF_DOCS -->
# SageMaker Unified Studio Blueprint Bootstrap

This submodule creates the foundational IAM roles required before any blueprint can be configured in an Amazon SageMaker Unified Studio domain.

## What it does

- Creates the **[AmazonSageMakerProvisioning](https://docs.aws.amazon.com/sagemaker-unified-studio/latest/adminguide/AmazonSageMakerProvisioning.html) IAM role** that mirrors the default managed IAM role created by the console. The role is used by Amazon SageMaker Unified Studio to provision and manage resources defined in the selected blueprints in your account.
- Creates the **[AmazonSageMakerManageAccess](https://docs.aws.amazon.com/sagemaker-unified-studio/latest/adminguide/AmazonSageMakerManageAccess.html) IAM role** that mirrors the default managed IAM role created by the console. The role grants Amazon SageMaker Unified Studio permissions to publish, grant access, and revoke access to Amazon SageMaker Lakehouse, AWS Glue Data Catalog and Amazon Redshift data. It also grants Amazon SageMaker Unified Studio access to publish and manage subscriptions on Amazon SageMaker Catalog data and AI assets.
- Creates a custom Redshift secret access policy scoped to the domain

## When to use this submodule

- **Domain created via the root module** — bootstrap is called automatically as part of the domain module. You do not need to invoke it separately.
- **Domain created outside Terraform** (e.g., through the AWS console or CLI) — you must call this submodule explicitly to create the required IAM roles before configuring any blueprints.

This submodule exists as a standalone entry point so that users with existing domains (not managed by the root module) can still set up the prerequisite roles needed for blueprint configuration.

## Usage

```hcl
module "bootstrap" {
  source = "./modules/blueprint-bootstrap"

  domain_id = "dzd-abc123xyz"  # Your existing domain ID

  tags = {
    Environment = "production"
  }
}
```

## Important notes

- This submodule should be invoked once per domain, before configuring any blueprints
- Role creation can be skipped with `create_provisioning_role = false` or `create_manage_access_role = false` if roles already exist

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.sagemaker_manage_access_redshift](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.sagemaker_manage_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.sagemaker_provisioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.glue_manage_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.redshift_manage_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.sagemaker_manage_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.sagemaker_manage_access_custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.sagemaker_provisioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain_id"></a> [domain\_id](#input\_domain\_id) | The ID of the SageMaker Unified Studio domain | `string` | n/a | yes |
| <a name="input_create_manage_access_role"></a> [create\_manage\_access\_role](#input\_create\_manage\_access\_role) | ARN of existing ManageAccess role. If not provided, the role is looked up or auto-created. | `bool` | `true` | no |
| <a name="input_create_provisioning_role"></a> [create\_provisioning\_role](#input\_create\_provisioning\_role) | ARN of existing Provisioning role. If not provided, the role is looked up or auto-created. | `bool` | `true` | no |
| <a name="input_domain_account_id"></a> [domain\_account\_id](#input\_domain\_account\_id) | AWS account ID where the domain resides. Defaults to the current account. Set this for cross-account blueprints so IAM trust policies grant the domain account permission to assume roles. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources created by this module | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_create_manage_access_role"></a> [create\_manage\_access\_role](#output\_create\_manage\_access\_role) | Whether the ManageAccess role was created by this module |
| <a name="output_create_provisioning_role"></a> [create\_provisioning\_role](#output\_create\_provisioning\_role) | Whether the Provisioning role was created by this module |
| <a name="output_manage_access_role_arn"></a> [manage\_access\_role\_arn](#output\_manage\_access\_role\_arn) | ARN of the ManageAccess role (created, existing, or user-provided) |
| <a name="output_provisioning_role_arn"></a> [provisioning\_role\_arn](#output\_provisioning\_role\_arn) | ARN of the Provisioning role (created, existing, or user-provided) |
<!-- END_TF_DOCS -->