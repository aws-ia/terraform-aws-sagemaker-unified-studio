<!-- BEGIN_TF_DOCS -->
# SageMaker Unified Studio Project Module

This module creates a single Amazon SageMaker Unified Studio project from a project profile. Membership management lives in the separate `project-membership` module (`modules/project-membership`); this module focuses on the project resource itself.

## What it does

- Creates a SageMaker Unified Studio project linked to a project profile
- Supports user parameters for environment configuration overrides
- Manages project memberships for owners and contributors
- Handles environment cleanup on destroy (deletes all environments before removing the project)
- Optionally cleans up the linked project profile on destroy when `enable_profile_cleanup = true`

## Usage

Standard project (no ToolingLite):

```hcl
module "project" {
  source = "./modules/project"

  domain_id          = module.domain.domain_id
  project_name       = "my-analytics-project"
  project_profile_id = module.sql_analytics_profile.project_profile_id
}
```

Bring-your-own-role project on a ToolingLite profile:

```hcl
module "project" {
  source = "./modules/project"

  domain_id          = module.domain.domain_id
  project_name       = "my-byor-project"
  project_profile_id = module.default_project_profile.project_profile_id
  project_role       = aws_iam_role.project_iam_role.arn
}
```

## Adding members

Use the `project-membership` module to add SSO users, SSO groups, and IAM principals to the project after creation. Principals are grouped into owner and contributor sets:

```hcl
module "project_membership" {
  source = "./modules/project-membership"

  domain_id  = module.domain.domain_id
  project_id = module.project.project_id

  project_owners = {
    iam_roles = ["arn:aws:iam::123456789012:role/MyAdmin"]
  }

  project_contributors = {
    sso_users  = ["analyst@example.com"]
    sso_groups = ["12345678-1234-1234-1234-123456789012"]
  }
}
```

The membership module validates each identifier format, biases a principal that appears in both sets toward owner, and verifies SSO user/group profiles exist in the domain before attempting to add them.

## Destroy behavior

On `terraform destroy`, the module automatically:

1. Lists and deletes all environments in the project
2. Waits for environment deletion to complete (up to 5 minutes)
3. Attempts force-cleanup of any environments stuck in `DELETE_FAILED` state
4. Optionally cleans up the linked project profile when `enable_profile_cleanup = true`

This requires the AWS CLI to be available and configured with appropriate permissions on the system running `terraform destroy`.

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
| [awscc_datazone_project.main](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/datazone_project) | resource |
| [awscc_datazone_project_membership.contributors](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/datazone_project_membership) | resource |
| [awscc_datazone_project_membership.members](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/datazone_project_membership) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [awscc_datazone_project_profile.this](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/data-sources/datazone_project_profile) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain_id"></a> [domain\_id](#input\_domain\_id) | The ID of the SageMaker Unified Studio domain | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project | `string` | n/a | yes |
| <a name="input_project_profile_id"></a> [project\_profile\_id](#input\_project\_profile\_id) | ID of the project profile to use for this project | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region for API calls during cleanup | `string` | `null` | no |
| <a name="input_contributor_list"></a> [contributor\_list](#input\_contributor\_list) | List of user identifiers to add as project contributors | `list(string)` | `[]` | no |
| <a name="input_project_description"></a> [project\_description](#input\_project\_description) | Description of the project | `string` | `"SageMaker Unified Studio project created with Terraform"` | no |
| <a name="input_project_role"></a> [project\_role](#input\_project\_role) | Specify the project role if the project profile is defined with ToolingLite. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the project | `map(string)` | `{}` | no |
| <a name="input_user_designation"></a> [user\_designation](#input\_user\_designation) | Designation for users in the user\_list | `string` | `"PROJECT_OWNER"` | no |
| <a name="input_user_list"></a> [user\_list](#input\_user\_list) | List of user identifiers to add as project owners | `list(string)` | `[]` | no |
| <a name="input_user_parameters"></a> [user\_parameters](#input\_user\_parameters) | User parameters for environment configurations | <pre>list(object({<br/>    environment_configuration_name = string<br/>    environment_parameters = list(object({<br/>      name  = string<br/>      value = string<br/>    }))<br/>  }))</pre> | `[]` | no |

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