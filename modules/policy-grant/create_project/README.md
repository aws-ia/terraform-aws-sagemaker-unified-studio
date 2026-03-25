<!-- BEGIN_TF_DOCS -->
# SageMaker Unified Studio Policy Grant — Create Project

This module grants principals the ability to create projects from specified project profiles within a domain unit.

## What it does

- Creates `CREATE_PROJECT_FROM_PROJECT_PROFILE` policy grants on a domain unit
- Supports granting access to individual users, groups, or all users in the domain
- Optionally includes child domain units in the grant scope

## Usage

```hcl
# Grant all users the ability to create projects from any profile
module "create_project_grant" {
  source = "./modules/policy-grant/create_project"

  domain_id           = module.domain.domain_id
  domain_unit_id      = module.domain.root_domain_unit_id
  project_profile_ids = [module.sql_analytics_profile.project_profile_id]
  all_users           = true
}

# Grant specific users
module "create_project_grant_team" {
  source = "./modules/policy-grant/create_project"

  domain_id           = module.domain.domain_id
  domain_unit_id      = module.domain.root_domain_unit_id
  project_profile_ids = [module.sql_analytics_profile.project_profile_id]
  user_principals     = ["user1@example.com", "user2@example.com"]
}
```

## Principal types

Only one principal type should be used per invocation:

- `all_users = true` — grants access to every user in the domain (overrides user/group lists)
- `user_principals` — list of individual user identifiers
- `group_principals` — list of group identifiers

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.28.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 1.68.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_awscc"></a> [awscc](#provider\_awscc) | >= 1.68.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [awscc_datazone_policy_grant.this](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/datazone_policy_grant) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain_id"></a> [domain\_id](#input\_domain\_id) | The ID of the DataZone domain. | `string` | n/a | yes |
| <a name="input_domain_unit_id"></a> [domain\_unit\_id](#input\_domain\_unit\_id) | The domain unit ID that owns the project profiles. All granted profiles must belong to this domain unit. | `string` | n/a | yes |
| <a name="input_project_profile_ids"></a> [project\_profile\_ids](#input\_project\_profile\_ids) | List of project profile IDs to grant access to. All must belong to the same domain unit specified by domain\_unit\_id. | `list(string)` | n/a | yes |
| <a name="input_all_users"></a> [all\_users](#input\_all\_users) | Whether to grant access to all users in the domain. | `bool` | `false` | no |
| <a name="input_group_principals"></a> [group\_principals](#input\_group\_principals) | List of group identifiers to grant access to. | `list(string)` | `[]` | no |
| <a name="input_include_child_domain_units"></a> [include\_child\_domain\_units](#input\_include\_child\_domain\_units) | Specifies whether to include child domain units when creating a project from project profile policy grant details | `bool` | `true` | no |
| <a name="input_user_principals"></a> [user\_principals](#input\_user\_principals) | List of individual user identifiers to grant access to. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_domain_id"></a> [domain\_id](#output\_domain\_id) | The domain ID. |
| <a name="output_domain_unit_id"></a> [domain\_unit\_id](#output\_domain\_unit\_id) | The domain unit ID that owns the project profiles. |
| <a name="output_grant_ids"></a> [grant\_ids](#output\_grant\_ids) | Map of principal keys to their policy grant IDs. |
<!-- END_TF_DOCS -->