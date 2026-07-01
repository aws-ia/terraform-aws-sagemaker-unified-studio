<!-- BEGIN_TF_DOCS -->
# SageMaker Unified Studio Domain Management Portal & Bring-Your-Own-Role Example

This example deploys a SageMaker Unified Studio domain configured for **bring-your-own-role (BYOR)** project provisioning using the **Default Project Profile**. BYOR is the modern alternative to the standard Tooling blueprint: rather than letting DataZone auto-create per-project execution roles, you supply your own IAM role at project creation time.

Optionally, the example also enables the new **domain management portal** experience. The domain management portal is an in-app administrative experience within SageMaker Unified Studio for managing the domain, its projects, project profiles, blueprints, and members. When enabled, this example also creates a singleton **admin project** that acts as the provisioner for BYOR projects, so per-project execution roles are issued through the admin project's execution role instead of a static provisioning role.

For background on these concepts, see [Further reading](#further-reading) at the end of this document.

## What this example deploys

### Domain (root module)

- A SageMaker Unified Studio **domain** with the standard Tooling blueprint, IAM roles, and S3 bucket
- Provisioning role gets an additional `s3:CreateBucket` / `s3:Get*` / `s3:Put*` policy on `arn:aws:s3:::amazon-sagemaker*` so default projects can self-provision their bucket

### Default Project Profile

- Enables **ToolingLite**, **S3Bucket**, and **S3TableCatalog** blueprints on the domain
- Creates the special **Default Project Profile** required for BYOR projects
- Optionally configures ToolingLite with the same VPC and subnets used by the domain's standard Tooling blueprint

### Domain Management Portal (optional)

When `create_domain_management_portal = true`:

- Creates the singleton admin project (`project_category = ADMIN`) that acts as the provisioner for BYOR projects
- The default project profile defers to the admin project's auto-created execution role rather than attaching a static provisioning role to the blueprints for `ON_CREATE` environments.

When `create_domain_management_portal = false` (default):

- The blueprint module's provisioning role is used to provision projects
- Memberships under `domain_admins` are not allowed and will fail the plan with a clear error

### Default Project + IAM execution role

- A dedicated IAM role (`SMUSProjectIAMExecutionRole_<random>`) is created with the `SageMakerStudioUserIAMDefaultExecutionPolicy` managed policy attached
- A single project is created from the Default Project Profile using that role as the BYOR `projectRoleArn`

### Memberships

Three principal sets, each accepting any combination of SSO users, SSO groups, IAM users, and IAM roles:

- `domain_admins` → admin project as `PROJECT_OWNER` (only when `create_domain_management_portal = true`)
- `project_owners` → default project as `PROJECT_OWNER`
- `project_contributors` → default project as `PROJECT_CONTRIBUTOR`

Each set is an object with `sso_users`, `sso_groups`, `iam_users`, and `iam_roles` lists.

Profiles are registered automatically before members are added: SSO users and IAM users as `aws_datazone_user_profile` entries (`user_type` `SSO_USER` and `IAM_USER` respectively), and SSO groups as `awscc_datazone_group_profile` entries. IAM roles are added directly without a profile.

## Prerequisites

1. **AWS CLI** configured with appropriate permissions
2. **Terraform** >= 1.5 installed
3. **AWS Account** with SageMaker Unified Studio available in your region
4. A VPC and subnets to attach to ToolingLite (or omit `vpc_id` / `subnet_ids` to use the domain's default VPC discovery)

## Quick start

1. Copy `terraform.tfvars.example` to `terraform.tfvars` and fill in domain name, region, VPC details, and the principal sets

2. Initialize and apply:

```bash
terraform init
terraform apply
```

## Variables of interest

| Variable | Purpose |
|---|---|
| `create_domain_management_portal` | When `true`, creates the admin project and uses it as the provisioner for BYOR projects |
| `vpc_id`, `subnet_ids` | Attach VPC/Subnets to ToolingLite. Both required together |
| `domain_admins` | `{ sso_users, sso_groups, iam_users, iam_roles }` added to the admin project |
| `project_owners` | `{ sso_users, sso_groups, iam_users, iam_roles }` added to the default project as owners |
| `project_contributors` | `{ sso_users, sso_groups, iam_users, iam_roles }` added to the default project as contributors |
| `enable_sso` | Enables IAM Identity Center SSO on the domain |

## Module composition

This example is a reference implementation. The individual sub-modules can be consumed directly for production use cases:

| Module | Path | Purpose |
|---|---|---|
| Domain (root) | `../..` | Domain, Tooling blueprint, IAM roles, S3 bucket, model governance |
| Default Project Profile | `../../modules/default-project-profile` | ToolingLite + S3Bucket + S3TableCatalog and the BYOR profile |
| Domain Management Portal | `../../modules/domain-management-portal` | Singleton admin project that provisions BYOR projects |
| Project | `../../modules/project` | Create a project from a profile, with optional `project_role` for BYOR |
| Membership | `../../modules/project-membership` | Add owner/contributor principal sets (SSO users/groups, IAM users, IAM roles) to a project |
| Policy Grant: Create Project | `../../modules/policy-grant-create-project` | Grant CREATE\_PROJECT\_FROM\_PROJECT\_PROFILE on a domain unit |

## Further reading

- [Amazon SageMaker Unified Studio concepts](https://docs.aws.amazon.com/sagemaker-unified-studio/latest/userguide/concepts.html) — domains, projects, project profiles, and blueprints
- [Project profiles](https://docs.aws.amazon.com/sagemaker-unified-studio/latest/userguide/projects.html) — configuration templates that define which blueprints a project is created from
- [Create a project](https://docs.aws.amazon.com/sagemaker-unified-studio/latest/userguide/getting-started-create-a-project.html) — creating a project from a project profile
- [Project role](https://docs.aws.amazon.com/sagemaker-unified-studio/latest/userguide/adding-existing-s3-data.html) — the IAM role associated with a project, which BYOR lets you supply
- [Admin setup for IAM-based domains](https://docs.aws.amazon.com/sagemaker-unified-studio/latest/userguide/gs-admin-setup.html) — domain administration, roles, and blueprint enablement

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.51.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 1.89.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.8.1 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.13.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.51.0 |
| <a name="provider_awscc"></a> [awscc](#provider\_awscc) | >= 1.89.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.8.1 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |
| <a name="provider_time"></a> [time](#provider\_time) | >= 0.13.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_admin_project"></a> [admin\_project](#module\_admin\_project) | ../../modules/domain-management-portal | n/a |
| <a name="module_admin_project_membership"></a> [admin\_project\_membership](#module\_admin\_project\_membership) | ../../modules/project-membership | n/a |
| <a name="module_create_project_from_project_profile_grant"></a> [create\_project\_from\_project\_profile\_grant](#module\_create\_project\_from\_project\_profile\_grant) | ../../modules/policy-grant-create-project | n/a |
| <a name="module_default_project"></a> [default\_project](#module\_default\_project) | ../../modules/project | n/a |
| <a name="module_default_project_membership"></a> [default\_project\_membership](#module\_default\_project\_membership) | ../../modules/project-membership | n/a |
| <a name="module_default_project_profile"></a> [default\_project\_profile](#module\_default\_project\_profile) | ../../modules/default-project-profile | n/a |
| <a name="module_domain"></a> [domain](#module\_domain) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_datazone_user_profile.iam_users](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/datazone_user_profile) | resource |
| [aws_datazone_user_profile.sso_users](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/datazone_user_profile) | resource |
| [aws_iam_role.project_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.project_iam_role_pass_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.project_iam_role_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.provisioning_admin_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [awscc_datazone_group_profile.sso_groups](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/datazone_group_profile) | resource |
| [random_id.project_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_string.project_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [terraform_data.admin_project_membership_precondition](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [time_sleep.wait_after_project_role_creation](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_subnets.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region where the domain will be created | `string` | `"us-east-1"` | no |
| <a name="input_create_domain_management_portal"></a> [create\_domain\_management\_portal](#input\_create\_domain\_management\_portal) | When set to true, the new project and domain management experience will be enabled an and Adminstrator project will be created and used for bring-your-own-role project provisioning. When set to false the admin portal will not be created and bring-your-role projects will be created by the provisioning role. | `bool` | `false` | no |
| <a name="input_domain_admins"></a> [domain\_admins](#input\_domain\_admins) | Principals to add to the admin project as owners. Only used when create\_domain\_management\_portal = true. | <pre>object({<br/>    sso_users  = optional(list(string), [])<br/>    sso_groups = optional(list(string), [])<br/>    iam_users  = optional(list(string), [])<br/>    iam_roles  = optional(list(string), [])<br/>  })</pre> | `{}` | no |
| <a name="input_domain_description"></a> [domain\_description](#input\_domain\_description) | Description of the SageMaker Unified Studio domain | `string` | `"SageMaker Unified Studio domain with modular blueprint and profile setup"` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Name of the SageMaker Unified Studio domain | `string` | `"terraform-quick-setup-domain"` | no |
| <a name="input_enable_sso"></a> [enable\_sso](#input\_enable\_sso) | Enable single sign on (SSO) using the default IAM Identity Center instance for the region | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (e.g., dev, staging, prod) | `string` | `"test"` | no |
| <a name="input_model_consumption_role_arn"></a> [model\_consumption\_role\_arn](#input\_model\_consumption\_role\_arn) | ARN of existing AmazonDataZoneBedrockFMConsumptionRole. If null, auto-created by the domain module. | `string` | `null` | no |
| <a name="input_model_management_role_arn"></a> [model\_management\_role\_arn](#input\_model\_management\_role\_arn) | ARN of existing AmazonDataZoneBedrockModelManagementRole. If null, auto-created by the domain module. | `string` | `null` | no |
| <a name="input_owner"></a> [owner](#input\_owner) | Owner of the domain (for tagging purposes) | `string` | `"terraform-quick-setup"` | no |
| <a name="input_project_contributors"></a> [project\_contributors](#input\_project\_contributors) | Principals to add to the default project as PROJECT\_CONTRIBUTOR. | <pre>object({<br/>    sso_users  = optional(list(string), [])<br/>    sso_groups = optional(list(string), [])<br/>    iam_users  = optional(list(string), [])<br/>    iam_roles  = optional(list(string), [])<br/>  })</pre> | `{}` | no |
| <a name="input_project_description"></a> [project\_description](#input\_project\_description) | Description of the project | `string` | `"Quick-setup project created with Terraform for SageMaker Unified Studio"` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project to create | `string` | `"terraform-quick-setup-project"` | no |
| <a name="input_project_owners"></a> [project\_owners](#input\_project\_owners) | Principals to add to the default project as PROJECT\_OWNER. | <pre>object({<br/>    sso_users  = optional(list(string), [])<br/>    sso_groups = optional(list(string), [])<br/>    iam_users  = optional(list(string), [])<br/>    iam_roles  = optional(list(string), [])<br/>  })</pre> | `{}` | no |
| <a name="input_project_role_arn"></a> [project\_role\_arn](#input\_project\_role\_arn) | Bring-your-own-role: ARN of an existing IAM role to use as the project execution role. When null (default), the example creates and manages its own project execution role. | `string` | `null` | no |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | Existing S3 bucket name for Tooling blueprint storage. If null, a dedicated bucket is created by the domain module. | `string` | `null` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet IDs for blueprint regional parameters. If null, subnets from the default VPC are used. | `list(string)` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_user_role_policy_arns"></a> [user\_role\_policy\_arns](#input\_user\_role\_policy\_arns) | List of IAM policy ARNs to apply as user role policies on the Tooling blueprint | `list(string)` | `null` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID for blueprint regional parameters. If null, the default VPC is used. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | AWS account ID where resources are created |
| <a name="output_domain_arn"></a> [domain\_arn](#output\_domain\_arn) | ARN of the created SageMaker Unified Studio domain |
| <a name="output_domain_execution_role_arn"></a> [domain\_execution\_role\_arn](#output\_domain\_execution\_role\_arn) | ARN of the domain execution role |
| <a name="output_domain_id"></a> [domain\_id](#output\_domain\_id) | ID of the created SageMaker Unified Studio domain |
| <a name="output_domain_name"></a> [domain\_name](#output\_domain\_name) | Name of the created SageMaker Unified Studio domain |
| <a name="output_domain_root_unit_id"></a> [domain\_root\_unit\_id](#output\_domain\_root\_unit\_id) | Root domain unit ID of the domain |
| <a name="output_domain_service_role_arn"></a> [domain\_service\_role\_arn](#output\_domain\_service\_role\_arn) | ARN of the domain service role |
| <a name="output_domain_url"></a> [domain\_url](#output\_domain\_url) | Portal URL for accessing the SageMaker Unified Studio domain |
| <a name="output_manage_access_role_arn"></a> [manage\_access\_role\_arn](#output\_manage\_access\_role\_arn) | ARN of the manage access role (from domain module) |
| <a name="output_provisioning_role_arn"></a> [provisioning\_role\_arn](#output\_provisioning\_role\_arn) | ARN of the provisioning role (from domain module) |
| <a name="output_region"></a> [region](#output\_region) | AWS region where resources are created |
| <a name="output_s3_bucket_name"></a> [s3\_bucket\_name](#output\_s3\_bucket\_name) | S3 bucket name used by the domain |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | Subnet IDs used for blueprint configurations |
| <a name="output_tooling_blueprint_id"></a> [tooling\_blueprint\_id](#output\_tooling\_blueprint\_id) | ID of the Tooling blueprint (created by the domain module) |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPC ID used for blueprint configurations |
<!-- END_TF_DOCS -->