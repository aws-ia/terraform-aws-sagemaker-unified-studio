<!-- BEGIN_TF_DOCS -->
# SageMaker Unified Studio Domain Management Portal Module

This module creates the singleton **Administration project** for an Amazon SageMaker Unified Studio domain that serves as the provisioner for bring-your-own-role projects when the new domain management portal experience is enabled.

## What it does

- Creates exactly one `awscc_datazone_project` with `project_category = "ADMIN"`, named `admin-project-<account_id>`, attached to the domain's root domain unit
- Verifies (precondition) that the **Tooling** blueprint is configured for the domain in the current region before attempting to create the project
- Adds a deterministic propagation wait (`time_sleep`) after project creation so the auto-provisioned `datazone_usr_role_*` execution role has time to become visible to IAM

## Usage

Basic creation:

```hcl
module "admin_project" {
  source    = "./modules/project/admin"
  domain_id = module.domain.domain_id
}
```

## Outputs of interest

- `project_id` — the DataZone project ID, available as soon as the API confirms creation
- `admin_role_arn` / `admin_role_name` — deterministic ARN and name for the auto-created project execution role (`datazone_usr_role_<project_id>_<domain_id_without_dzd_prefix>`). Useful when attaching extra IAM policies or referencing the role in other modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.51.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 1.89.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.51.0 |
| <a name="provider_awscc"></a> [awscc](#provider\_awscc) | >= 1.89.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [awscc_datazone_project.admin_project](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/datazone_project) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_datazone_domain.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/datazone_domain) | data source |
| [aws_datazone_environment_blueprint.tooling](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/datazone_environment_blueprint) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [awscc_datazone_environment_blueprint_configuration.tooling](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/data-sources/datazone_environment_blueprint_configuration) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain_id"></a> [domain\_id](#input\_domain\_id) | The ID of the SageMaker Unified Studio domain | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | AWS account ID where project is created |
| <a name="output_admin_role_arn"></a> [admin\_role\_arn](#output\_admin\_role\_arn) | ARN of the DataZone-managed admin/user execution role for this project |
| <a name="output_admin_role_name"></a> [admin\_role\_name](#output\_admin\_role\_name) | Name of the DataZone-managed admin/user execution role for this project |
| <a name="output_domain_id"></a> [domain\_id](#output\_domain\_id) | Domain ID where project is created |
| <a name="output_project_description"></a> [project\_description](#output\_project\_description) | Description of the created project |
| <a name="output_project_id"></a> [project\_id](#output\_project\_id) | ID of the created project |
| <a name="output_project_name"></a> [project\_name](#output\_project\_name) | Name of the created project |
| <a name="output_project_url"></a> [project\_url](#output\_project\_url) | URL to access the project in SageMaker Unified Studio |
| <a name="output_region"></a> [region](#output\_region) | AWS region where project is created |
<!-- END_TF_DOCS -->