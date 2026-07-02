<!-- BEGIN_TF_DOCS -->
# SageMaker Unified Studio Default Project Profile Module

This module enables the blueprints needed to support the special "Default Project Profile" used for bring-your-own-role (BYOR) projects in SageMaker Unified Studio, then creates the profile itself. The Default Project Profile is separated from the standard project-profile module because BYOR projects can only be created from a specifically configured Default Project Profile that uses the ToolingLite blueprint.

## What it does

- Enables three managed blueprints on the domain:
  - **ToolingLite** — drives BYOR project creation
  - **S3Bucket** — on-demand S3 bucket environments
  - **S3TableCatalog** — on-demand S3 Tables catalog environments
- Creates `CREATE_ENVIRONMENT_FROM_BLUEPRINT` policy grants on the root domain unit (with `include_child_domain_units = true`) for each blueprint
- Optionally configures ToolingLite with a VPC and subnets matching the standard Tooling blueprint
- Creates the `awscc_datazone_project_profile` named "Default Project Profile" with all three blueprints wired up in the correct deployment order
- When the admin project is not in use, attaches `SageMakerStudioAdminIAMDefaultExecutionPolicy` to the provisioning role so it has the permissions needed to set up default projects

## Provisioning role resolution

Resolution order when `using_domain_management_portal = false`:

1. `var.provisioning_role_arn` if explicitly provided
2. Existing IAM role created by `modules/blueprint-bootstrap`, looked up by the conventional name `AmazonSageMakerProvisioning-<account_id>-<domain_id>` under path `/service-role/`
3. If neither is available, the plan fails early with a clear error message

When `using_domain_management_portal = true`, the provisioning role ARN is left null on each blueprint configuration so the admin project's execution role acts as the provisioner for ON\_CREATE blueprints.

Self-serve ON\_DEMAND blueprints (S3TablesCatalog and S3Bucket) are always defined without a provisioning role; by default the project execution role will act as the provisioner for ON\_DEMAND blueprints.

## VPC configuration (optional)

`vpc_id` and `subnet_ids` must be provided together. When both are set:

- ToolingLite is configured with `regional_parameters` containing `VpcId` and a comma-joined `Subnets` value, matching the regional parameter shape used by the standard Tooling blueprint
- Each subnet is validated to belong to the specified VPC at plan time

When neither is set, ToolingLite is enabled in the current region without VPC parameters. Setting only one of the two fails the plan with a cross-variable validation error.

S3Bucket and S3TableCatalog do not take VPC parameters and are unaffected by this configuration.

## Usage

Without VPC configuration, using a bootstrap-created provisioning role:

```hcl
module "default_project_profile" {
  source = "./modules/project-profile/default"

  domain_id = module.domain.domain_id
}
```

With explicit provisioning role and VPC configuration:

```hcl
module "default_project_profile" {
  source = "./modules/project-profile/default"

  domain_id             = module.domain.domain_id
  provisioning_role_arn = module.domain.provisioning_role_arn
  vpc_id                = local.vpc_id
  subnet_ids            = local.subnet_ids
}
```

When an admin project is acting as the provisioner:

```hcl
module "default_project_profile" {
  source = "./modules/project-profile/default"

  domain_id                       = module.domain.domain_id
  using_domain_management_portal  = true
}
```

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
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_datazone_environment_blueprint_configuration.s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/datazone_environment_blueprint_configuration) | resource |
| [aws_datazone_environment_blueprint_configuration.s3_table_catalog](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/datazone_environment_blueprint_configuration) | resource |
| [aws_datazone_environment_blueprint_configuration.tooling_lite](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/datazone_environment_blueprint_configuration) | resource |
| [awscc_datazone_policy_grant.s3_bucket_policy_grant](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/datazone_policy_grant) | resource |
| [awscc_datazone_policy_grant.s3_table_catalog_policy_grant](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/datazone_policy_grant) | resource |
| [awscc_datazone_policy_grant.tooling_lite_policy_grant](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/datazone_policy_grant) | resource |
| [awscc_datazone_project_profile.this](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/datazone_project_profile) | resource |
| [terraform_data.provisioning_role_validation](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.subnet_vpc_validation](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.vpc_config_validation](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_datazone_domain.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/datazone_domain) | data source |
| [aws_datazone_environment_blueprint.s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/datazone_environment_blueprint) | data source |
| [aws_datazone_environment_blueprint.s3_table_catalog](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/datazone_environment_blueprint) | data source |
| [aws_datazone_environment_blueprint.tooling_lite](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/datazone_environment_blueprint) | data source |
| [aws_iam_roles.provisioning_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_roles) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_subnet.validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain_id"></a> [domain\_id](#input\_domain\_id) | The ID of the SageMaker Unified Studio domain | `string` | n/a | yes |
| <a name="input_provisioning_role_arn"></a> [provisioning\_role\_arn](#input\_provisioning\_role\_arn) | ARN of existing Provisioning role. If not provided, the role is looked up by name. If neither is found, the module will fail — use the bootstrap submodule to create roles first. | `string` | `null` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet IDs to attach to the ToolingLite blueprint configuration. Must be provided together with vpc\_id. All subnets must belong to vpc\_id. | `list(string)` | `null` | no |
| <a name="input_using_domain_management_portal"></a> [using\_domain\_management\_portal](#input\_using\_domain\_management\_portal) | Set to true if a domain management portal (admin project) is used. The admin project's execution role acts as provisioner for the ToolingLite blueprints, so var.provisioning\_role\_arn is ignored. | `bool` | `false` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID to attach to the ToolingLite blueprint configuration. Must be provided together with subnet\_ids. When both are set, the ToolingLite blueprint is enabled with the same VPC/Subnets regional parameters used by the standard Tooling blueprint. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_project_profile_id"></a> [project\_profile\_id](#output\_project\_profile\_id) | The ID of the created default project profile |
| <a name="output_s3_bucket_blueprint_id"></a> [s3\_bucket\_blueprint\_id](#output\_s3\_bucket\_blueprint\_id) | Environment blueprint ID for S3Bucket |
| <a name="output_s3_table_catalog_blueprint_id"></a> [s3\_table\_catalog\_blueprint\_id](#output\_s3\_table\_catalog\_blueprint\_id) | Environment blueprint ID for S3TableCatalog |
| <a name="output_tooling_lite_blueprint_id"></a> [tooling\_lite\_blueprint\_id](#output\_tooling\_lite\_blueprint\_id) | Environment blueprint ID for ToolingLite |
<!-- END_TF_DOCS -->