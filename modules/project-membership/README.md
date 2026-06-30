<!-- BEGIN_TF_DOCS -->
# SageMaker Unified Studio Project Membership Module

This module wires up the members of a SageMaker Unified Studio project from two principal sets: `project_owners` (granted `PROJECT_OWNER`) and `project_contributors` (granted `PROJECT_CONTRIBUTOR`). Each set accepts any combination of SSO users, SSO groups, IAM users, and IAM roles, and the module creates one membership per principal via `for_each`.

## What it does

- Flattens both principal sets into a single keyed map and creates one `awscc_datazone_project_membership` per unique principal
- Routes each principal into the correct membership field based on its type:
  - `SSO_USER` and `IAM_USER` → `member.user_identifier`
  - `SSO_GROUP` and `IAM_ROLE` → `member.group_identifier`
- For SSO members, looks up the corresponding DataZone user or group profile in the domain and fails the plan with a clear error message if it isn't registered

## Uniqueness and owner bias

Memberships are keyed by **identifier**, so each principal results in exactly one membership:

- Duplicate identifiers listed more than once within a set are collapsed (via `distinct()`)
- When the same identifier appears in **both** `project_owners` and `project_contributors`, ownership wins — the principal is granted `PROJECT_OWNER` only. The owner set is merged last so it takes precedence over the contributor set.

This means a principal is always either an owner or a contributor, never both.

## IAM user vs IAM role

DataZone treats an IAM user and an IAM role as different kinds of principal, so each set distinguishes them:

- `iam_users` — specific IAM user ARNs (e.g. `arn:aws:iam::123456789012:user/alice`). Passed in `member.user_identifier`, the same field used for individual SSO users.
- `iam_roles` — IAM role ARNs (e.g. `arn:aws:iam::123456789012:role/MyRole`). Passed in `member.group_identifier`, because a role represents an assumable identity shared by many sessions rather than a single user.

The validation rejects a role ARN supplied under `iam_users` and a user ARN supplied under `iam_roles`.

## Validations

**Variable-level (run at plan time before any data source reads):**

- `domain_id` must match the `dzd[-_]...` format
- `project_id` must be non-empty
- For each of `project_owners` and `project_contributors`:
  - every `sso_users` entry must be a non-empty string
  - every `sso_groups` entry must be an identity store group UUID
  - every `iam_users` entry must be a valid IAM user ARN (any partition)
  - every `iam_roles` entry must be a valid IAM role ARN (any partition)

**Resource-level preconditions:**

- Each `SSO_USER` must already have a DataZone user profile in the domain (e.g. created via `aws_datazone_user_profile`)
- Each `SSO_GROUP` must already have a DataZone group profile in the domain

## Usage

```hcl
module "project_membership" {
  source = "./modules/project-membership"

  domain_id  = module.domain.domain_id
  project_id = module.project.project_id

  project_owners = {
    sso_users = ["jdoe@example.com"]
    iam_roles = ["arn:aws:iam::123456789012:role/MyAdmin"]
  }

  project_contributors = {
    sso_users  = ["analyst@example.com"]
    sso_groups = ["12345678-1234-1234-1234-123456789012"]
    iam_users  = ["arn:aws:iam::123456789012:user/alice"]
  }
}
```

Both sets default to empty, so you can supply only the ones you need.

## Notes

- DataZone project memberships have no update API — every property is create-only. The module keys each membership by its full identity (`designation|member_type|identifier`), so any change (including switching a principal between owner and contributor) is realized as a destroy-and-recreate rather than an in-place update, which would otherwise fail with `NotUpdatableException`.
- SSO users and groups must be registered as `aws_datazone_user_profile` / `awscc_datazone_group_profile` in the domain before being added. The `examples/quick-setup` example shows the typical pattern of unioning principals from both sets and registering each one once.
- IAM users and IAM roles are routed to different membership fields (`user_identifier` vs `group_identifier`), so place each ARN under the matching key.

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_awscc"></a> [awscc](#provider\_awscc) | n/a |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [awscc_datazone_project_membership.this](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/datazone_project_membership) | resource |
| [terraform_data.member_identity](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [awscc_datazone_group_profile.sso_group](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/data-sources/datazone_group_profile) | data source |
| [awscc_datazone_user_profile.sso_user](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/data-sources/datazone_user_profile) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain_id"></a> [domain\_id](#input\_domain\_id) | ID of the SageMaker Unified Studio domain that owns the project. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | ID of the SageMaker Unified Studio project to add the member to. | `string` | n/a | yes |
| <a name="input_project_contributors"></a> [project\_contributors](#input\_project\_contributors) | Principals to add to the created project as PROJECT\_CONTRIBUTOR. | <pre>object({<br/>    sso_users  = optional(list(string), [])<br/>    sso_groups = optional(list(string), [])<br/>    iam_users  = optional(list(string), [])<br/>    iam_roles  = optional(list(string), [])<br/>  })</pre> | `{}` | no |
| <a name="input_project_owners"></a> [project\_owners](#input\_project\_owners) | Principals to add to the created project as PROJECT\_OWNER. | <pre>object({<br/>    sso_users  = optional(list(string), [])<br/>    sso_groups = optional(list(string), [])<br/>    iam_users  = optional(list(string), [])<br/>    iam_roles  = optional(list(string), [])<br/>  })</pre> | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->