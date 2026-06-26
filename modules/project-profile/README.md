<!-- BEGIN_TF_DOCS -->
# SageMaker Unified Studio Project Profile Module

This module creates a single project profile for an Amazon SageMaker Unified Studio domain. A project profile defines which environment blueprints are available when creating a project, along with their deployment order and configuration parameters.

For the special "Default Project Profile" used for bring-your-own-role (BYOR) projects with the ToolingLite blueprint, see `modules/project-profile/default` instead.

## What it does

- Creates one `awscc_datazone_project_profile` per invocation
- Automatically includes Tooling as the first environment (`deployment_order = 1`)
- Orders remaining blueprints alphabetically starting at `deployment_order = 2`
- Resolves blueprint IDs internally from blueprint names via data source lookup
- Validates that all referenced blueprints are configured (enabled) for the domain before creating the profile
- Supports per-blueprint region overrides and parameter overrides
- Supports a `blueprint_dependencies` input that establishes a real dependency edge to upstream blueprint modules so the profile is created after blueprints are configured

## Usage

```hcl
module "sql_analytics_profile" {
  source = "./modules/project-profile"

  domain_id   = module.domain.domain_id
  name        = "SQL analytics"
  description = "Analyze your data in SageMaker Lakehouse using SQL"

  blueprints = {
    Tooling            = {}
    DataLake           = { parameter_overrides = { glueDbName = { value = "glue_db" } } }
    LakehouseCatalog   = { deployment_mode = "ON_DEMAND" }
    RedshiftServerless = { deployment_mode = "ON_DEMAND" }
  }

  # Pass through entity_id from each upstream blueprint module so the profile
  # waits for blueprint configurations to be applied first.
  blueprint_dependencies = [for bp in module.blueprints : bp.entity_id]
}
```

## Blueprint configuration

Each entry in `blueprints` accepts:

- `description` — optional description for the environment configuration
- `deployment_mode` — `ON_CREATE` (default) or `ON_DEMAND`
- `region` — override the AWS region for this blueprint (defaults to the current region)
- `parameter_overrides` — map of parameter name to `{ value, is_editable }` for customizing blueprint defaults

Tooling is always added at `deployment_order = 1`. Other blueprints are placed in alphabetical order starting at `deployment_order = 2`.

## Output behavior

The `project_profile_id` output declares `depends_on` on the underlying `awscc_datazone_project_profile` resource. Downstream modules that reference this output will automatically wait for the profile to be fully created before being evaluated, which prevents unknown-value plan errors and "AWS Data Source Not Found" race conditions.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.51.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 1.89.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.37.0 |
| <a name="provider_awscc"></a> [awscc](#provider\_awscc) | >= 1.76.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [awscc_datazone_project_profile.this](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/datazone_project_profile) | resource |
| [terraform_data.blueprint_dependencies](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_datazone_domain.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/datazone_domain) | data source |
| [aws_datazone_environment_blueprint.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/datazone_environment_blueprint) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [awscc_datazone_environment_blueprint_configuration.this](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/data-sources/datazone_environment_blueprint_configuration) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_blueprints"></a> [blueprints](#input\_blueprints) | Map of blueprints to include in this project profile.<br/>Key = blueprint name (e.g., "Tooling", "DataLake", "RedshiftServerless").<br/>The blueprint ID is resolved internally via data lookup.<br/><br/>Tooling must always be included and automatically gets deployment\_order = 1.<br/>Note: For EmrOnEks, you must provide eksClusterArn in parameter\_overrides.<br/><br/>Example:<br/>  blueprints = {<br/>    Tooling            = {}<br/>    DataLake           = { region = "us-west-2", parameter\_overrides = { glueDbName = { value = "my\_db" } } }<br/>    RedshiftServerless = {<br/>      deployment\_mode = "ON\_DEMAND"<br/>      region          = "eu-west-1"<br/>      parameter\_overrides = {<br/>        redshiftBaseCapacity = { value = "256", is\_editable = true }<br/>      }<br/>    }<br/>  } | <pre>map(object({<br/>    description     = optional(string)<br/>    deployment_mode = optional(string, "ON_CREATE")<br/>    region          = optional(string)<br/>    parameter_overrides = optional(map(object({<br/>      value       = string<br/>      is_editable = optional(bool, false)<br/>    })), {})<br/>  }))</pre> | n/a | yes |
| <a name="input_domain_id"></a> [domain\_id](#input\_domain\_id) | The ID of the SageMaker Unified Studio domain | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the project profile | `string` | n/a | yes |
| <a name="input_blueprint_dependencies"></a> [blueprint\_dependencies](#input\_blueprint\_dependencies) | List of blueprint entity IDs to ensure they are created before the profile. Pass the entity\_id output from each blueprint module. This prevents race conditions when blueprints and profiles are deployed in the same apply. | `list(string)` | `[]` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the project profile | `string` | `null` | no |
| <a name="input_domain_unit_id"></a> [domain\_unit\_id](#input\_domain\_unit\_id) | The domain unit ID that owns the project profile. If not provided, the module will use the root domain unit. | `string` | `null` | no |
| <a name="input_status"></a> [status](#input\_status) | Status of the project profile (ENABLED or DISABLED) | `string` | `"ENABLED"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_blueprint_count"></a> [blueprint\_count](#output\_blueprint\_count) | Number of blueprints in this project profile |
| <a name="output_blueprint_names"></a> [blueprint\_names](#output\_blueprint\_names) | List of blueprint names included in this project profile |
| <a name="output_name"></a> [name](#output\_name) | The name of the project profile |
| <a name="output_project_profile_id"></a> [project\_profile\_id](#output\_project\_profile\_id) | The ID of the created project profile |
<!-- END_TF_DOCS -->