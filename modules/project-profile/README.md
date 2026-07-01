<!-- BEGIN_TF_DOCS -->
# SageMaker Unified Studio Project Profile Module

This module creates a single project profile for an Amazon SageMaker Unified Studio domain. A project profile defines which environment blueprints are available when creating a project, along with their deployment order, target account and region, and configuration parameters.

## What it does

- Creates one `awscc_datazone_project_profile` per invocation
- Automatically includes Tooling as the first environment (deployment\_order = 0); you do not add a Tooling entry yourself
- Assigns `ON_CREATE` blueprints deployment\_order = 1 and omits the deployment order for `ON_DEMAND` blueprints, sorting each group alphabetically for a stable, position-correlated ordering
- Resolves blueprint IDs internally from the managed blueprint name via data source lookup
- Validates that all referenced blueprints are configured (enabled) for the domain before creating the profile
- Supports per-blueprint region overrides and parameter overrides
- Allows multiple environment configurations to reference the same blueprint (e.g. an `ON_CREATE` and an `ON_DEMAND` Redshift Serverless)

## Usage

The `blueprints` map key is the **environment configuration name**, and each entry's
`blueprint` attribute is the **managed blueprint name** that gets resolved to a
blueprint ID. This lets you compose several configurations from the same blueprint.

```hcl
module "sql_analytics_profile" {
  source = "./modules/project-profile"

  domain_id   = module.domain.domain_id
  name        = "SQL analytics"
  description = "Analyze your data in SageMaker Lakehouse using SQL"

  blueprints = {
    "Lakehouse Database" = {
      blueprint       = "DataLake"
      deployment_mode = "ON_CREATE"
      parameter_overrides = { glueDbName = { value = "glue_db", is_editable = true } }
    }
    "Redshift Serverless" = {
      blueprint       = "RedshiftServerless"
      deployment_mode = "ON_CREATE"
    }
    "OnDemand Catalog for RMS" = {
      blueprint       = "LakehouseCatalog"
      deployment_mode = "ON_DEMAND"
    }
  }

  blueprint_dependencies = [for bp in module.blueprints : bp.entity_id]
}
```

## Blueprint configuration

The map key is always treated as the environment configuration name. Each entry accepts:

- `blueprint` (required) — the managed blueprint name to resolve to a blueprint ID (e.g. `DataLake`, `RedshiftServerless`, `QuickSight`)
- `description` — optional description for the environment configuration
- `deployment_mode` — `ON_CREATE` (default) or `ON_DEMAND`
- `region` — override the AWS region for this blueprint (defaults to current region)
- `parameter_overrides` — map of parameter name to `{ value, is_editable }` for customizing blueprint defaults

Note: For `EmrOnEks`, you must provide `eksClusterArn` in `parameter_overrides`.

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
| [awscc_datazone_project_profile.this](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/datazone_project_profile) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_datazone_domain.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/datazone_domain) | data source |
| [aws_datazone_environment_blueprint.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/datazone_environment_blueprint) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [awscc_datazone_environment_blueprint_configuration.this](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/data-sources/datazone_environment_blueprint_configuration) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_blueprints"></a> [blueprints](#input\_blueprints) | Map of environment configurations to include in this project profile.<br/><br/>Key = the environment configuration name (e.g., "OnDemand Redshift Serverless").<br/>`blueprint` (required) = the managed blueprint name to resolve to a blueprint ID<br/>via data lookup (e.g., "RedshiftServerless", "DataLake", "QuickSight").<br/><br/>The map key is always treated as the configuration name only; the blueprint is<br/>always resolved from the `blueprint` attribute. This allows multiple configurations<br/>to reference the same blueprint (e.g., an ON\_CREATE and an ON\_DEMAND Redshift).<br/><br/>Tooling is added automatically (deployment\_order = 0) and does not need an entry.<br/>Note: For EmrOnEks, you must provide eksClusterArn in parameter\_overrides.<br/><br/>Example:<br/>  blueprints = {<br/>    "Lakehouse Database" = {<br/>      blueprint       = "DataLake"<br/>      deployment\_mode = "ON\_CREATE"<br/>      parameter\_overrides = { glueDbName = { value = "glue\_db", is\_editable = true } }<br/>    }<br/>    "OnDemand Redshift Serverless" = {<br/>      blueprint       = "RedshiftServerless"<br/>      deployment\_mode = "ON\_DEMAND"<br/>      region          = "eu-west-1"<br/>      parameter\_overrides = {<br/>        redshiftBaseCapacity = { value = "256", is\_editable = true }<br/>      }<br/>    }<br/>  } | <pre>map(object({<br/>    blueprint       = string<br/>    description     = optional(string)<br/>    deployment_mode = optional(string, "ON_CREATE")<br/>    region          = optional(string)<br/>    parameter_overrides = optional(map(object({<br/>      value       = string<br/>      is_editable = optional(bool, false)<br/>    })), {})<br/>  }))</pre> | n/a | yes |
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