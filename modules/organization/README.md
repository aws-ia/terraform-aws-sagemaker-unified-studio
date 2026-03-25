<!-- BEGIN_TF_DOCS -->
# SageMaker Unified Studio Organization Module

This module discovers AWS Organization accounts for multi-account domain resource sharing. It replaces the Lambda-based account discovery used in the equivalent CloudFormation setup.

## What it does

- Queries AWS Organizations to list all accounts
- Filters to active accounts only
- Optionally excludes the management account
- Supports overriding with a specific list of account IDs
- Outputs the filtered account list for use with the resource-sharing module

## Usage

```hcl
module "organization" {
  source = "./modules/organization"

  organization_id            = "o-abc1234567"
  exclude_management_account = true
}

module "resource_sharing" {
  source = "./modules/resource-sharing"

  domain_id   = module.domain.domain_id
  domain_arn  = module.domain.domain_arn
  domain_name = module.domain.domain_name

  account_ids = module.organization.accounts_for_sharing
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [terraform_data.organization_validation](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_organizations_organization.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization) | data source |
| [aws_organizations_organizational_units.root](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organizational_units) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_email_filter"></a> [account\_email\_filter](#input\_account\_email\_filter) | Optional regex pattern to filter accounts by email | `string` | `null` | no |
| <a name="input_account_name_filter"></a> [account\_name\_filter](#input\_account\_name\_filter) | Optional regex pattern to filter accounts by name | `string` | `null` | no |
| <a name="input_exclude_management_account"></a> [exclude\_management\_account](#input\_exclude\_management\_account) | Whether to exclude the management account from resource sharing | `bool` | `true` | no |
| <a name="input_organization_id"></a> [organization\_id](#input\_organization\_id) | AWS Organizations ID for multi-account setup (matches CloudFormation OrganizationId parameter) | `string` | `null` | no |
| <a name="input_specific_account_ids"></a> [specific\_account\_ids](#input\_specific\_account\_ids) | Specific list of account IDs to share with (overrides organization discovery if provided) | `list(string)` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to organization-related resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_ids_comma_separated"></a> [account\_ids\_comma\_separated](#output\_account\_ids\_comma\_separated) | Account IDs as comma-separated string (matches CloudFormation format) |
| <a name="output_accounts_for_sharing"></a> [accounts\_for\_sharing](#output\_accounts\_for\_sharing) | Filtered account IDs for resource sharing (equivalent to CloudFormation AccountsForResourceShare) |
| <a name="output_accounts_for_sharing_count"></a> [accounts\_for\_sharing\_count](#output\_accounts\_for\_sharing\_count) | Number of accounts that will receive resource shares |
| <a name="output_active_accounts"></a> [active\_accounts](#output\_active\_accounts) | Detailed information about active accounts in the organization |
| <a name="output_all_account_ids"></a> [all\_account\_ids](#output\_all\_account\_ids) | All account IDs in the organization (equivalent to Lambda function output) |
| <a name="output_configuration_summary"></a> [configuration\_summary](#output\_configuration\_summary) | Summary of organization configuration |
| <a name="output_current_account_id"></a> [current\_account\_id](#output\_current\_account\_id) | Current AWS account ID |
| <a name="output_current_region"></a> [current\_region](#output\_current\_region) | Current AWS region |
| <a name="output_organization_arn"></a> [organization\_arn](#output\_organization\_arn) | AWS Organizations ARN (if enabled) |
| <a name="output_organization_enabled"></a> [organization\_enabled](#output\_organization\_enabled) | Whether AWS Organizations integration is enabled |
| <a name="output_organization_id"></a> [organization\_id](#output\_organization\_id) | AWS Organizations ID (if enabled) |
| <a name="output_organization_master_account_id"></a> [organization\_master\_account\_id](#output\_organization\_master\_account\_id) | AWS Organizations master account ID (if enabled) |
<!-- END_TF_DOCS -->