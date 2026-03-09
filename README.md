<!-- BEGIN_TF_DOCS -->
# Terraform Module Project

:no\_entry\_sign: Do not edit this readme.md file. To learn how to change this content and work with this repository, refer to CONTRIBUTING.md

## Readme Content

This file will contain any instructional information about this module.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.28.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 1.68.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.28.0 |
| <a name="provider_awscc"></a> [awscc](#provider\_awscc) | >= 1.68.0 |
| <a name="provider_time"></a> [time](#provider\_time) | >= 0.9 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_datazone_domain.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/datazone_domain) | resource |
| [aws_iam_policy.manage_access_redshift_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.domain_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.domain_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.sagemaker_manage_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.sagemaker_provisioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.domain_execution_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.domain_service_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.manage_access_glue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.manage_access_redshift](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.manage_access_redshift_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.manage_access_sagemaker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.sagemaker_provisioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_s3_bucket.domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_logging.domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_public_access_block.domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [awscc_datazone_environment_blueprint_configuration.tooling](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/datazone_environment_blueprint_configuration) | resource |
| [awscc_datazone_project.model_governance_project](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/datazone_project) | resource |
| [awscc_datazone_project_profile.model_governance_project_profile](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/datazone_project_profile) | resource |
| [time_sleep.domain_propagation](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_datazone_domain.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/datazone_domain) | data source |
| [aws_datazone_environment_blueprint.tooling](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/datazone_environment_blueprint) | data source |
| [aws_iam_roles.domain_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_roles) | data source |
| [aws_iam_roles.domain_service_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_roles) | data source |
| [aws_iam_roles.provisioning_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_roles) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet IDs for Tooling blueprint regional parameters | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID for Tooling blueprint regional parameters | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Description of the domain | `string` | `"SageMaker Unified Studio domain managed by Terraform"` | no |
| <a name="input_domain_execution_role_arn"></a> [domain\_execution\_role\_arn](#input\_domain\_execution\_role\_arn) | ARN of the domain execution role for SageMaker Unified Studio | `string` | `null` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Name of the DataZone domain (matches CloudFormation DomainName parameter) | `string` | `null` | no |
| <a name="input_domain_service_role_arn"></a> [domain\_service\_role\_arn](#input\_domain\_service\_role\_arn) | ARN of the domain service role for SageMaker Unified Studio | `string` | `null` | no |
| <a name="input_enable_sso"></a> [enable\_sso](#input\_enable\_sso) | Choose to enable single sign on (SSO) and use an existing AWS IAM Identity Center Instance. When set to true, this will use the default IAM IDC instance that is enabled for the account within the same region as the domain. | `bool` | `false` | no |
| <a name="input_kms_key_identifier"></a> [kms\_key\_identifier](#input\_kms\_key\_identifier) | ARN of the KMS key used to encrypt the Amazon DataZone domain, metadata and reporting data (if null, uses AWS managed key) | `string` | `null` | no |
| <a name="input_manage_access_role_arn"></a> [manage\_access\_role\_arn](#input\_manage\_access\_role\_arn) | ARN of existing AmazonSageMakerManageAccess role. If not provided, the role is auto-created. | `string` | `null` | no |
| <a name="input_provisioning_role_arn"></a> [provisioning\_role\_arn](#input\_provisioning\_role\_arn) | ARN of existing AmazonSageMakerProvisioning role. If not provided, the role is auto-created. | `string` | `null` | no |
| <a name="input_query_execution_role_arn"></a> [query\_execution\_role\_arn](#input\_query\_execution\_role\_arn) | ARN of a custom query execution role for the Tooling blueprint. If not provided, the service uses the default AmazonSageMakerQueryExecution role. | `string` | `null` | no |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | Existing S3 bucket name for Tooling blueprint storage. If null, a dedicated bucket is created. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the domain and related resources | `map(string)` | `{}` | no |
| <a name="input_user_role_policy_arns"></a> [user\_role\_policy\_arns](#input\_user\_role\_policy\_arns) | List of IAM policy ARNs to apply as user role policies on the Tooling blueprint. Defaults to SageMakerStudioProjectUserRolePolicy if not provided. | `list(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | AWS Account ID where the domain is created |
| <a name="output_domain_arn"></a> [domain\_arn](#output\_domain\_arn) | ARN of the SageMaker Unified Studio domain |
| <a name="output_domain_execution_role_arn"></a> [domain\_execution\_role\_arn](#output\_domain\_execution\_role\_arn) | ARN of the domain execution role (created or existing) |
| <a name="output_domain_execution_role_created"></a> [domain\_execution\_role\_created](#output\_domain\_execution\_role\_created) | Whether the domain execution role was created by this module (false if it already existed) |
| <a name="output_domain_execution_role_name"></a> [domain\_execution\_role\_name](#output\_domain\_execution\_role\_name) | Name of the domain execution role |
| <a name="output_domain_id"></a> [domain\_id](#output\_domain\_id) | ID of the SageMaker Unified Studio domain |
| <a name="output_domain_name"></a> [domain\_name](#output\_domain\_name) | Name of the SageMaker Unified Studio domain |
| <a name="output_domain_root_unit_id"></a> [domain\_root\_unit\_id](#output\_domain\_root\_unit\_id) | Actual root domain unit ID (not domain ID) |
| <a name="output_domain_service_role_arn"></a> [domain\_service\_role\_arn](#output\_domain\_service\_role\_arn) | ARN of the domain service role (created or existing) |
| <a name="output_domain_service_role_created"></a> [domain\_service\_role\_created](#output\_domain\_service\_role\_created) | Whether the domain service role was created by this module (false if it already existed) |
| <a name="output_domain_service_role_name"></a> [domain\_service\_role\_name](#output\_domain\_service\_role\_name) | Name of the domain service role |
| <a name="output_domain_url"></a> [domain\_url](#output\_domain\_url) | Portal URL of the SageMaker Unified Studio domain |
| <a name="output_manage_access_role_arn"></a> [manage\_access\_role\_arn](#output\_manage\_access\_role\_arn) | ARN of the manage access role (created or provided). Pass to blueprint modules. |
| <a name="output_provisioning_role_arn"></a> [provisioning\_role\_arn](#output\_provisioning\_role\_arn) | ARN of the provisioning role (created or provided). Pass to blueprint modules. |
| <a name="output_region"></a> [region](#output\_region) | AWS Region where the domain is created |
| <a name="output_s3_bucket_name"></a> [s3\_bucket\_name](#output\_s3\_bucket\_name) | S3 bucket name used by the Tooling blueprint (created or provided) |
| <a name="output_tooling_blueprint_id"></a> [tooling\_blueprint\_id](#output\_tooling\_blueprint\_id) | ID of the Tooling environment blueprint |
<!-- END_TF_DOCS -->