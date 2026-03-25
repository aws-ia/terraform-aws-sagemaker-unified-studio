<!-- BEGIN_TF_DOCS -->
# SageMaker Unified Studio Resource Sharing Module

This module creates AWS RAM resource shares to share an Amazon SageMaker Unified Studio domain with other AWS accounts, enabling multi-account domain access.

## What it does

- Creates an AWS RAM resource share for the DataZone domain
- Associates the domain ARN with the resource share
- Shares the domain with specified AWS account IDs
- Attaches the `AmazonDatazoneDomainExtendedServiceAccess` RAM permission
- Optionally auto-accepts shares for accounts within the same organization
- Supports excluding the current account from the share list

## Usage

```hcl
module "resource_sharing" {
  source = "./modules/resource-sharing"

  domain_id   = module.domain.domain_id
  domain_arn  = module.domain.domain_arn
  domain_name = module.domain.domain_name

  account_ids = ["123456789012", "987654321098"]

  tags = {
    Environment = "production"
  }
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
| [aws_ram_permission_association.domain_permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_permission_association) | resource |
| [aws_ram_principal_association.account_associations](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_principal_association) | resource |
| [aws_ram_resource_association.domain_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_association) | resource |
| [aws_ram_resource_share.domain_share](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_share) | resource |
| [aws_ram_resource_share_accepter.domain_share_accepter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_share_accepter) | resource |
| [terraform_data.sharing_validation](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_ram_permission.datazone_domain_permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ram_permission) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_ids"></a> [account\_ids](#input\_account\_ids) | List of AWS account IDs to share the domain with (matches CloudFormation AccountsForResourceShare parameter) | `list(string)` | n/a | yes |
| <a name="input_domain_arn"></a> [domain\_arn](#input\_domain\_arn) | SageMaker Unified Studio domain ARN (matches CloudFormation DomainARN parameter) | `string` | n/a | yes |
| <a name="input_domain_id"></a> [domain\_id](#input\_domain\_id) | SageMaker Unified Studio domain ID (matches CloudFormation DomainId parameter) | `string` | n/a | yes |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | SageMaker Unified Studio domain name (matches CloudFormation DomainName parameter) | `string` | n/a | yes |
| <a name="input_allow_external_principals"></a> [allow\_external\_principals](#input\_allow\_external\_principals) | Whether to allow sharing with external principals (outside organization) | `bool` | `false` | no |
| <a name="input_auto_accept_shares"></a> [auto\_accept\_shares](#input\_auto\_accept\_shares) | Whether to automatically accept resource shares (for same organization) | `bool` | `true` | no |
| <a name="input_enable_resource_sharing"></a> [enable\_resource\_sharing](#input\_enable\_resource\_sharing) | Whether to enable resource sharing (allows conditional sharing) | `bool` | `true` | no |
| <a name="input_exclude_current_account"></a> [exclude\_current\_account](#input\_exclude\_current\_account) | Whether to exclude the current account from resource sharing | `bool` | `true` | no |
| <a name="input_resource_share_name"></a> [resource\_share\_name](#input\_resource\_share\_name) | Custom name for the resource share (if null, will use DataZone-{domain\_name}-{domain\_id}) | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resource sharing resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_permission_arn"></a> [permission\_arn](#output\_permission\_arn) | ARN of the DataZone domain permission used |
| <a name="output_permission_name"></a> [permission\_name](#output\_permission\_name) | Name of the DataZone domain permission used |
| <a name="output_principal_associations"></a> [principal\_associations](#output\_principal\_associations) | Map of principal associations (account ID -> association ARN) |
| <a name="output_resource_association_arn"></a> [resource\_association\_arn](#output\_resource\_association\_arn) | ARN of the resource association |
| <a name="output_resource_share_arn"></a> [resource\_share\_arn](#output\_resource\_share\_arn) | ARN of the created resource share |
| <a name="output_resource_share_id"></a> [resource\_share\_id](#output\_resource\_share\_id) | ID of the created resource share |
| <a name="output_resource_share_name"></a> [resource\_share\_name](#output\_resource\_share\_name) | Name of the created resource share |
| <a name="output_resource_share_status"></a> [resource\_share\_status](#output\_resource\_share\_status) | Status of the resource share |
| <a name="output_shared_with_accounts"></a> [shared\_with\_accounts](#output\_shared\_with\_accounts) | List of account IDs that the domain is shared with |
| <a name="output_shared_with_accounts_count"></a> [shared\_with\_accounts\_count](#output\_shared\_with\_accounts\_count) | Number of accounts the domain is shared with |
| <a name="output_sharing_enabled"></a> [sharing\_enabled](#output\_sharing\_enabled) | Whether resource sharing is enabled |
| <a name="output_sharing_summary"></a> [sharing\_summary](#output\_sharing\_summary) | Summary of resource sharing configuration |
<!-- END_TF_DOCS -->