<!-- BEGIN_TF_DOCS -->
# SageMaker Unified Studio Blueprint Module

This module configures a single environment blueprint for an Amazon SageMaker Unified Studio domain. It is designed to be invoked once per blueprint, using `for_each` or multiple `module` blocks to configure as many blueprints as needed.

## What it does

- Resolves the blueprint ID from its name via data source lookup
- Configures the blueprint with provisioning and manage-access IAM roles
- Sets regional parameters (VPC, subnets, S3 location) when required
- Sets global parameters (e.g., query execution role ARN) when required
- Grants `CREATE_ENVIRONMENT_FROM_BLUEPRINT` policy to specified domain units
- Validates that subnets belong to the specified VPC
- Validates that required IAM roles exist before applying

## Submodules

### `bootstrap`

Creates the foundational IAM roles and Lake Formation settings required before any blueprint can be configured:

- `AmazonSageMakerProvisioning` IAM role
- `AmazonSageMakerManageAccess` IAM role
- Lake Formation data lake admin settings
- Custom Redshift secret access policy

The bootstrap submodule should be invoked once per domain, before configuring any blueprints.

## Usage

```hcl
# First, bootstrap IAM roles (once per domain)
module "bootstrap" {
  source    = "./modules/blueprint/bootstrap"
  domain_id = module.domain.domain_id
}

# Then configure each blueprint
module "blueprints" {
  source = "./modules/blueprint"

  for_each = var.blueprint_configs

  domain_id           = module.domain.domain_id
  blueprint_name      = each.value.name
  regional_parameters = each.value.regional_parameters
  global_parameters   = each.value.global_parameters

  depends_on = [module.bootstrap]
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.28.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 1.68.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.28.0 |
| <a name="provider_awscc"></a> [awscc](#provider\_awscc) | >= 1.68.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |
| <a name="provider_time"></a> [time](#provider\_time) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_datazone_environment_blueprint_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/datazone_environment_blueprint_configuration) | resource |
| [awscc_datazone_environment_blueprint_configuration.this](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/datazone_environment_blueprint_configuration) | resource |
| [awscc_datazone_policy_grant.this](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/datazone_policy_grant) | resource |
| [terraform_data.manage_access_role_validation](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.provisioning_role_validation](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.subnet_vpc_validation](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [time_sleep.blueprint_propagation](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_datazone_domain.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/datazone_domain) | data source |
| [aws_datazone_environment_blueprint.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/datazone_environment_blueprint) | data source |
| [aws_iam_roles.manage_access_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_roles) | data source |
| [aws_iam_roles.provisioning_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_roles) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_subnet.validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_blueprint_name"></a> [blueprint\_name](#input\_blueprint\_name) | Name of the blueprint to configure (e.g., LakehouseCatalog, MLExperiments, RedshiftServerless). The blueprint ID is resolved internally via data lookup — if the name is invalid, the data source will fail with a clear error. | `string` | n/a | yes |
| <a name="input_domain_id"></a> [domain\_id](#input\_domain\_id) | The ID of the SageMaker Unified Studio domain | `string` | n/a | yes |
| <a name="input_domain_account_id"></a> [domain\_account\_id](#input\_domain\_account\_id) | AWS account ID where the domain resides. Defaults to the current account. Set this for cross-account blueprints so IAM trust policies grant the domain account permission to assume roles. | `string` | `null` | no |
| <a name="input_domain_unit_ids"></a> [domain\_unit\_ids](#input\_domain\_unit\_ids) | A list of domain unit IDs to grant access to the blueprint. If not specified, the default root domain unit of the domain will be used. | `list(string)` | `[]` | no |
| <a name="input_global_parameters"></a> [global\_parameters](#input\_global\_parameters) | Map of the global parameters to attach to the project. | `map(string)` | `{}` | no |
| <a name="input_manage_access_role_arn"></a> [manage\_access\_role\_arn](#input\_manage\_access\_role\_arn) | ARN of existing ManageAccess role. If not provided, the role is looked up by name. If neither is found, the module will fail — use the bootstrap submodule to create roles first. | `string` | `null` | no |
| <a name="input_provisioning_role_arn"></a> [provisioning\_role\_arn](#input\_provisioning\_role\_arn) | ARN of existing Provisioning role. If not provided, the role is looked up by name. If neither is found, the module will fail — use the bootstrap submodule to create roles first. | `string` | `null` | no |
| <a name="input_regional_parameters"></a> [regional\_parameters](#input\_regional\_parameters) | Map of AWS regions to their infrastructure parameters (vpc\_id, subnet\_ids, s3\_bucket\_uri). Keys become enabled\_regions. Leave empty for blueprints that don't require regional parameters (e.g., QuickSight, Bedrock, MLflowApp, LakehouseAdmin). | <pre>map(object({<br>    vpc_id     = string<br>    subnet_ids = list(string)<br>    s3_uri     = string<br>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources created by this module | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_blueprint_id"></a> [blueprint\_id](#output\_blueprint\_id) | The environment blueprint ID (resolved from blueprint\_name) |
| <a name="output_blueprint_name"></a> [blueprint\_name](#output\_blueprint\_name) | The blueprint name that was configured |
| <a name="output_enabled_regions"></a> [enabled\_regions](#output\_enabled\_regions) | List of AWS regions where the blueprint is enabled |
| <a name="output_entity_id"></a> [entity\_id](#output\_entity\_id) | Entity identifier for policy grants (account\_id:blueprint\_id) |
| <a name="output_manage_access_role_source"></a> [manage\_access\_role\_source](#output\_manage\_access\_role\_source) | How the manage access role was resolved: 'variable' if passed via var, 'data\_lookup' if found by name |
| <a name="output_provisioning_role_source"></a> [provisioning\_role\_source](#output\_provisioning\_role\_source) | How the provisioning role was resolved: 'variable' if passed via var, 'data\_lookup' if found by name |
<!-- END_TF_DOCS -->