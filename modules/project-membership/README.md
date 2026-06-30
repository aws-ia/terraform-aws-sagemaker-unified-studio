<!-- BEGIN_TF_DOCS -->
# SageMaker Unified Studio Project Membership Module

This module adds a single principal to a SageMaker Unified Studio project with a specified role. Principal types supported: SSO users, SSO groups, IAM users, and IAM roles. To add multiple members, invoke the module multiple times via `for_each` keyed by principal.

## What it does

- Creates one `awscc_datazone_project_membership` per invocation, attaching the principal to the given project with `PROJECT_OWNER` or `PROJECT_CONTRIBUTOR` designation
- Routes the principal into the correct membership field based on `member_type`:
  - `SSO_USER` and `IAM_USER` → `member.user_identifier`
  - `SSO_GROUP` and `IAM_ROLE` → `member.group_identifier`
- For SSO members, looks up the corresponding DataZone user or group profile in the domain and fails the plan with a clear error message if it isn't registered

## IAM user vs IAM role

DataZone treats an IAM user and an IAM role as different kinds of principal, so this module exposes two distinct member types:

- `IAM_USER` — a specific IAM user ARN (e.g. `arn:aws:iam::123456789012:user/alice`). The ARN is passed in `member.user_identifier`, the same field used for individual SSO users.
- `IAM_ROLE` — an IAM role ARN (e.g. `arn:aws:iam::123456789012:role/MyRole`). The ARN is passed in `member.group_identifier`, because a role represents an assumable identity shared by many sessions rather than a single user.

Pick the type that matches the ARN you are adding; the validation rejects a role ARN supplied as `IAM_USER` and vice versa.

## Validations

**Variable-level (run at plan time before any data source reads):**

- `member_type` must be one of `SSO_USER`, `SSO_GROUP`, `IAM_USER`, `IAM_ROLE`
- `project_role` must be `PROJECT_OWNER` or `PROJECT_CONTRIBUTOR`
- `domain_id` must match the `dzd[-_]...` format
- `project_id` and `identifier` must be non-empty
- When `member_type = "IAM_USER"`, `identifier` must be a valid IAM user ARN (any partition)
- When `member_type = "IAM_ROLE"`, `identifier` must be a valid IAM role ARN (any partition)
- When `member_type = "SSO_GROUP"`, `identifier` must be a UUID

**Resource-level preconditions:**

- When `member_type = "SSO_USER"`, the user must already have a DataZone user profile in the domain (e.g. created via `aws_datazone_user_profile`)
- When `member_type = "SSO_GROUP"`, the group must already have a DataZone group profile in the domain

## Usage

Add an IAM role as a project owner:

```hcl
module "owner" {
  source = "./modules/project/membership"

  domain_id    = module.domain.domain_id
  project_id   = module.project.project_id
  member_type  = "IAM_ROLE"
  identifier   = "arn:aws:iam::123456789012:role/MyAdmin"
  project_role = "PROJECT_OWNER"
}
```

Add an IAM user as a contributor:

```hcl
module "iam_user" {
  source = "./modules/project/membership"

  domain_id    = module.domain.domain_id
  project_id   = module.project.project_id
  member_type  = "IAM_USER"
  identifier   = "arn:aws:iam::123456789012:user/alice"
  project_role = "PROJECT_CONTRIBUTOR"
}
```

Add multiple SSO users as contributors:

```hcl
module "contributors" {
  for_each = toset(var.sso_user_ids)
  source   = "./modules/project/membership"

  domain_id    = module.domain.domain_id
  project_id   = module.project.project_id
  member_type  = "SSO_USER"
  identifier   = each.value
  project_role = "PROJECT_CONTRIBUTOR"
}
```

Add an SSO group as a contributor:

```hcl
module "team" {
  source = "./modules/project/membership"

  domain_id    = module.domain.domain_id
  project_id   = module.project.project_id
  member_type  = "SSO_GROUP"
  identifier   = "12345678-1234-1234-1234-123456789012"
  project_role = "PROJECT_CONTRIBUTOR"
}
```

## Notes

- SSO users must be registered as `aws_datazone_user_profile` in the domain before being added. The `examples/tooling-lite` example shows the typical pattern of unioning SSO users from multiple principal sets and registering each one once.
- IAM users and IAM roles are routed to different membership fields (`user_identifier` vs `group_identifier`), so be sure to set `member_type` to match the kind of ARN you are passing.

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_awscc"></a> [awscc](#provider\_awscc) | 1.90.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [awscc_datazone_project_membership.this](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/datazone_project_membership) | resource |
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