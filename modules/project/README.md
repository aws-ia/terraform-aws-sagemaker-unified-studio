<!-- BEGIN_TF_DOCS -->
# SageMaker Unified Studio Project Module

This module creates a single Amazon SageMaker Unified Studio project and manages user memberships within it.

## What it does

- Creates a DataZone project, optionally linked to a project profile
- Supports user parameters for environment configuration overrides
- Manages project memberships for owners and contributors
- Handles environment cleanup on destroy (deletes all environments before removing the project)
- Optionally cleans up associated project profiles on destroy

## Usage

```hcl
module "project" {
  source = "./modules/project"

  domain_id          = module.domain.domain_id
  project_name       = "my-analytics-project"
  project_profile_id = module.sql_analytics_profile.project_profile_id

  user_list        = ["user1@example.com"]
  contributor_list = ["user2@example.com"]
}
```

## Destroy behavior

On `terraform destroy`, the module automatically:

1. Lists and deletes all environments in the project
2. Waits for environment deletion to complete (up to 5 minutes)
3. Attempts force-cleanup of any environments stuck in `DELETE_FAILED` state
4. Optionally cleans up project profiles when `enable_profile_cleanup = true`

This requires the AWS CLI to be available and configured with appropriate permissions.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_awscc"></a> [awscc](#provider\_awscc) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [awscc_datazone_project.main](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/datazone_project) | resource |
| [awscc_datazone_project_membership.contributors](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/datazone_project_membership) | resource |
| [awscc_datazone_project_membership.members](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/datazone_project_membership) | resource |
| [null_resource.cleanup_environments](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.cleanup_project_profiles](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain_id"></a> [domain\_id](#input\_domain\_id) | The ID of the SageMaker Unified Studio domain | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region for API calls during cleanup | `string` | `null` | no |
| <a name="input_contributor_list"></a> [contributor\_list](#input\_contributor\_list) | List of user identifiers to add as project contributors | `list(string)` | `[]` | no |
| <a name="input_enable_profile_cleanup"></a> [enable\_profile\_cleanup](#input\_enable\_profile\_cleanup) | Enable project profile cleanup during destroy | `bool` | `false` | no |
| <a name="input_project_description"></a> [project\_description](#input\_project\_description) | Description of the project | `string` | `"SageMaker Unified Studio project created with Terraform"` | no |
| <a name="input_project_profile_id"></a> [project\_profile\_id](#input\_project\_profile\_id) | ID of the project profile to use for this project (optional for V2 domains) | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the project | `map(string)` | `{}` | no |
| <a name="input_user_designation"></a> [user\_designation](#input\_user\_designation) | Designation for users in the user\_list | `string` | `"PROJECT_OWNER"` | no |
| <a name="input_user_list"></a> [user\_list](#input\_user\_list) | List of user identifiers to add as project owners | `list(string)` | `[]` | no |
| <a name="input_user_parameters"></a> [user\_parameters](#input\_user\_parameters) | User parameters for environment configurations | <pre>list(object({<br>    environment_configuration_name = string<br>    environment_parameters = list(object({<br>      name  = string<br>      value = string<br>    }))<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | AWS account ID where project is created |
| <a name="output_domain_id"></a> [domain\_id](#output\_domain\_id) | Domain ID where project is created |
| <a name="output_membership_details"></a> [membership\_details](#output\_membership\_details) | Detailed membership information |
| <a name="output_next_steps"></a> [next\_steps](#output\_next\_steps) | Information about next steps after project creation |
| <a name="output_project_contributors"></a> [project\_contributors](#output\_project\_contributors) | List of project contributor user identifiers |
| <a name="output_project_description"></a> [project\_description](#output\_project\_description) | Description of the created project |
| <a name="output_project_id"></a> [project\_id](#output\_project\_id) | ID of the created project |
| <a name="output_project_name"></a> [project\_name](#output\_project\_name) | Name of the created project |
| <a name="output_project_owners"></a> [project\_owners](#output\_project\_owners) | List of project owner user identifiers |
| <a name="output_project_profile_id"></a> [project\_profile\_id](#output\_project\_profile\_id) | Project profile ID used for this project |
| <a name="output_project_url"></a> [project\_url](#output\_project\_url) | URL to access the project in SageMaker Unified Studio |
| <a name="output_region"></a> [region](#output\_region) | AWS region where project is created |
| <a name="output_total_members"></a> [total\_members](#output\_total\_members) | Total number of project members |
| <a name="output_user_parameters"></a> [user\_parameters](#output\_user\_parameters) | User parameters configured for the project |
<!-- END_TF_DOCS -->