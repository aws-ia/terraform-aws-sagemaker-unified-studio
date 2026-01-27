<!-- BEGIN_TF_DOCS -->
# Terraform Module Project

:no\_entry\_sign: Do not edit this readme.md file. To learn how to change this content and work with this repository, refer to CONTRIBUTING.md

## Readme Content

This file will contain any instructional information about this module.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.28.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 1.68.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.28.0 |
| <a name="provider_awscc"></a> [awscc](#provider\_awscc) | >= 1.68.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_datazone_domain.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/datazone_domain) | resource |
| [awscc_datazone_project.model_governance_project](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/datazone_project) | resource |
| [awscc_datazone_project_profile.model_governance_project_profile](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/datazone_project_profile) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [awscc_datazone_domain.main](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/data-sources/datazone_domain) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_description"></a> [description](#input\_description) | Description of the domain | `string` | `"SageMaker Unified Studio domain managed by Terraform"` | no |
| <a name="input_domain_execution_role_arn"></a> [domain\_execution\_role\_arn](#input\_domain\_execution\_role\_arn) | ARN of the domain execution role for SageMaker Unified Studio | `string` | `null` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Name of the DataZone domain (matches CloudFormation DomainName parameter) | `string` | `null` | no |
| <a name="input_domain_service_role_arn"></a> [domain\_service\_role\_arn](#input\_domain\_service\_role\_arn) | ARN of the domain service role for SageMaker Unified Studio | `string` | `null` | no |
| <a name="input_enable_sso"></a> [enable\_sso](#input\_enable\_sso) | Choose to enable single sign on (SSO) and use an existing AWS IAM Identity Center Instance. When set to true, this will use the default IAM IDC instance that is enabled for the account within the same region as the domain. | `bool` | `false` | no |
| <a name="input_kms_key_identifier"></a> [kms\_key\_identifier](#input\_kms\_key\_identifier) | ARN of the KMS key used to encrypt the Amazon DataZone domain, metadata and reporting data (if null, uses AWS managed key) | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the domain and related resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | AWS Account ID where the domain is created |
| <a name="output_domain_arn"></a> [domain\_arn](#output\_domain\_arn) | ARN of the SageMaker Unified Studio domain |
| <a name="output_domain_execution_role_arn"></a> [domain\_execution\_role\_arn](#output\_domain\_execution\_role\_arn) | ARN of the domain execution role (created or existing) |
| <a name="output_domain_execution_role_name"></a> [domain\_execution\_role\_name](#output\_domain\_execution\_role\_name) | Name of the domain execution role |
| <a name="output_domain_id"></a> [domain\_id](#output\_domain\_id) | ID of the SageMaker Unified Studio domain |
| <a name="output_domain_name"></a> [domain\_name](#output\_domain\_name) | Name of the SageMaker Unified Studio domain |
| <a name="output_domain_root_unit_id"></a> [domain\_root\_unit\_id](#output\_domain\_root\_unit\_id) | Actual root domain unit ID (not domain ID) |
| <a name="output_domain_url"></a> [domain\_url](#output\_domain\_url) | Portal URL of the SageMaker Unified Studio domain |
| <a name="output_region"></a> [region](#output\_region) | AWS Region where the domain is created |
<!-- END_TF_DOCS -->