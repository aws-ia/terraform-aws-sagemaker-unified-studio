<!-- BEGIN_TF_DOCS -->
# SageMaker Unified Studio Cross-Account Domain Association Module

This module shares an existing SageMaker Unified Studio domain from the **source account** (the account that owns the domain) with a **destination account** (the associated account) using AWS RAM, accepts the share, and bootstraps the destination account with the IAM roles needed to host blueprint environments.

It does not create the domain itself. Use the root domain module in the source account first, then invoke this module to extend the domain to additional accounts.

## What it does

- Creates an `aws_ram_resource_share` in the source account, scoped with the `AWSRAMPermissionsAmazonDatazoneDomainExtendedServiceAccess` permission
- Associates the domain ARN with the share and the destination account as a principal
- Accepts the RAM share in the destination account via `aws_ram_resource_share_accepter` (skipped when `using_organizations = true`)
- Invokes `modules/blueprint/bootstrap` against the destination account to create the `AmazonSageMakerProvisioning-*` and `AmazonSageMakerManageAccess-*` IAM roles and to configure Lake Formation
- Validates at plan time that both providers are configured for the same AWS region (DataZone cross-account associations require region parity)

## Required providers

This module operates across two accounts and requires the caller to pass two configured `aws` providers via the `providers` map:

| Alias | Account |
|---|---|
| `aws.source` | Account that owns the SageMaker Unified Studio domain |
| `aws.destination` | Account being associated with the domain |

The module declares the alias contract via `configuration_aliases`; it does not configure credentials or regions. The caller is responsible for both.

## Manual prerequisites

Before applying this module:

1. **Create the domain in the source account** using the root module or the AWS console. You'll need the resulting `domain_id` (`dzd-...`) for `var.domain_id`.

2. **Configure two AWS provider profiles or credentials** — one for each account. Both must be in the same AWS region. The destination credentials must have permission to create IAM roles, accept RAM shares (when not using Organizations), and configure Lake Formation.

3. **(Recommended) Verify RAM share permissions** in the source account. If your account uses an SCP, RCP, or RAM permissions configuration that restricts external principals, you may need to allow `ram:AssociateResourceShare` and the `AWSRAMPermissionsAmazonDatazoneDomainExtendedServiceAccess` managed permission ARN.

4. **(If not using AWS Organizations)** The destination account holder will receive a RAM share invitation. The module accepts it automatically via `aws_ram_resource_share_accepter`, but the destination credentials must have `ram:AcceptResourceShareInvitation` permission. If you set `using_organizations = true`, the share is auto-accepted within the org and this step is skipped.

## Manual steps after `terraform apply`

This module handles the cross-account roles and RAM share. The following items are typically managed by other modules invoked separately against the **destination** account, but are listed here for the operator's checklist:

- **Configure blueprints in the destination account** for any environment types your projects will use. Invoke `modules/blueprint` with the `aws` provider pointing at the destination, passing the role ARNs from this module's outputs (`manage_access_role_arn`, `provisioning_role_arn`).

- **Add the destination account as an environment account** in any project profiles that should provision into it. Project profiles support per-environment-configuration `aws_account.aws_account_id` values.

- **Verify Lake Formation registration** if you plan to use SageMaker Lakehouse. The bootstrap submodule sets the destination's data lake admins; you may also need to register specific S3 locations.

- **(Manual, console-only)** If your domain uses identity center single-sign-on, end users from the destination account may need to log in once to create their DataZone user profile before they can be added as project members.

## Usage

Two-account setup, both in `us-east-1`, not using AWS Organizations:

```hcl
provider "aws" {
  alias   = "source"
  profile = "domain-account"
  region  = "us-east-1"
}

provider "aws" {
  alias   = "destination"
  profile = "associated-account"
  region  = "us-east-1"
}

module "cross_account" {
  source = "./modules/cross-account"

  providers = {
    aws.source      = aws.source
    aws.destination = aws.destination
  }

  domain_id           = "dzd-xxxxxxxxxxxx"
  using_organizations = false
}
```

Same setup but both accounts in the same AWS Organization (skip the manual share-accept step):

```hcl
module "cross_account" {
  source = "./modules/cross-account"

  providers = {
    aws.source      = aws.source
    aws.destination = aws.destination
  }

  domain_id           = "dzd-xxxxxxxxxxxx"
  using_organizations = true
}
```

## Outputs

| Output | Purpose |
|---|---|
| `domain_id` / `domain_arn` | The shared domain's identifiers |
| `source_account_id` / `destination_account_id` | Account context for downstream modules |
| `resource_share_arn` / `resource_share_name` | The RAM share for auditing or IAM scoping |
| `manage_access_role_arn` | Pass to `modules/blueprint` invocations against the destination |
| `provisioning_role_arn` | Pass to `modules/blueprint` invocations against the destination |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.19.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws.destination"></a> [aws.destination](#provider\_aws.destination) | >= 6.19.0 |
| <a name="provider_aws.source"></a> [aws.source](#provider\_aws.source) | >= 6.19.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bootstrap"></a> [bootstrap](#module\_bootstrap) | ../blueprint/bootstrap | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_ram_principal_association.domain_share_principal_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_principal_association) | resource |
| [aws_ram_resource_association.domain_share_domain_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_association) | resource |
| [aws_ram_resource_share.domain_share](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_share) | resource |
| [aws_ram_resource_share_accepter.receiver_accept](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_share_accepter) | resource |
| [terraform_data.region_consistency_validation](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [aws_caller_identity.alternate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_datazone_domain.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/datazone_domain) | data source |
| [aws_region.alternate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain_id"></a> [domain\_id](#input\_domain\_id) | The ID of the SageMaker Unified Studio domain | `string` | n/a | yes |
| <a name="input_bootstrap"></a> [bootstrap](#input\_bootstrap) | When set to true, this will create the provisioning and manage access roles in the destination account with the correct cross-account trust policy. These will be used for blueprint setup and cross-account resource provisioning. | `bool` | `true` | no |
| <a name="input_using_organizations"></a> [using\_organizations](#input\_using\_organizations) | Set to true if both the domain account (source account) and the account to be associated (destination account) are in an AWS organization. This will skip a manual resource share accepter step. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_destination_account_id"></a> [destination\_account\_id](#output\_destination\_account\_id) | AWS account ID that received the domain share (destination) |
| <a name="output_domain_id"></a> [domain\_id](#output\_domain\_id) | ID of the SageMaker Unified Studio domain that was shared |
| <a name="output_manage_access_role_arn"></a> [manage\_access\_role\_arn](#output\_manage\_access\_role\_arn) | ARN of the ManageAccess role created in the destination account by the bootstrap submodule |
| <a name="output_provisioning_role_arn"></a> [provisioning\_role\_arn](#output\_provisioning\_role\_arn) | ARN of the Provisioning role created in the destination account by the bootstrap submodule |
| <a name="output_resource_share_arn"></a> [resource\_share\_arn](#output\_resource\_share\_arn) | ARN of the RAM resource share created in the source account |
| <a name="output_resource_share_name"></a> [resource\_share\_name](#output\_resource\_share\_name) | Name of the RAM resource share created in the source account |
| <a name="output_source_account_id"></a> [source\_account\_id](#output\_source\_account\_id) | AWS account ID that owns the domain (source) |
<!-- END_TF_DOCS -->