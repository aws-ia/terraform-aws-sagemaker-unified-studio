<!-- BEGIN_TF_DOCS -->
# SageMaker Unified Studio Quick-Setup Example

This example aims to closely mirror the [AWS Console quick-setup experience](https://docs.aws.amazon.com/sagemaker-unified-studio/latest/userguide/quick-setup.html) for Amazon SageMaker Unified Studio as closely as possible using Terraform resources.

## What This Example Deploys

### Root Module (Domain)

- A SageMaker Unified Studio **domain** with the **Tooling blueprint** enabled
- All required **IAM roles** (domain execution, manage access, provisioning)
- **Model governance resources** (Bedrock model management and consumption roles)
- An **S3 bucket** for tooling environment storage

### Blueprint Module

- Enables the necessary **environment blueprints** based on which capabilities are toggled on (e.g. LakehouseCatalog, MLExperiments, RedshiftServerless, Bedrock blueprints, and more)

### Project Profile Module

- Creates the three default **project profiles** that mirror the console quick-setup:
  - **SQL Analytics** — Analyze data in SageMaker Lakehouse using SQL
  - **Generative AI Application Development** — Build generative AI applications powered by Amazon Bedrock
  - **All Capabilities** — Full suite including analytics, ML, and generative AI

### Project Module

- Deploys a basic **project** using the first available project profile from the ones created above

## Prerequisites

1. **AWS CLI** configured with appropriate permissions
2. **Terraform** >= 1.5 installed
3. **AWS Account** with SageMaker Unified Studio available in your region

## Quick Start

1. Review and update `terraform.tfvars` with your desired configuration (domain name, region, tags, etc.)

2. Initialize and apply:

```bash
terraform init
terraform apply
```

By default all three project profiles (SQL Analytics, Generative AI, All Capabilities) are enabled. You can toggle them individually via the `enable_sql_analytics`, `enable_generative_ai`, and `enable_all_capabilities` variables.

## Using the Sub-Modules Independently

This example is intended as a reference implementation. For production use cases, consume the individual sub-modules directly and compose them to fit your needs:

| Module | Path | Purpose |
|---|---|---|
| Domain (root) | `../..` | Domain, Tooling blueprint, IAM roles, S3 bucket, model governance |
| Blueprint | `../../modules/blueprint` | Enable a single environment blueprint on a domain |
| Project Profile | `../../modules/project-profile` | Compose blueprints into a deployable project profile |
| Project | `../../modules/project` | Create a project from a project profile |

For example, if you only need SQL Analytics you can invoke the domain module, enable just the relevant blueprints, and create a single project profile — no need to deploy the full quick-setup.

## Known Issues

### Policy-grant error on subsequent `terraform apply`

Running `terraform apply` a second time may produce an error indicating that the policy-grant resource already exists. This happens because the Terraform provider currently recreates the policy-grant resource rather than updating it in place, which conflicts with the existing grant.

This error does not affect the actual deployment — all other resources will still be created or updated safely. The policy-grant itself remains intact from the initial apply.

We are actively working with the engineering team to resolve this behavior in the provider.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.28.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 1.68.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.1 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.28.0 |
| <a name="provider_awscc"></a> [awscc](#provider\_awscc) | >= 1.68.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_all_capabilities_project_profile"></a> [all\_capabilities\_project\_profile](#module\_all\_capabilities\_project\_profile) | ../../modules/project-profile | n/a |
| <a name="module_blueprints"></a> [blueprints](#module\_blueprints) | ../../modules/blueprint | n/a |
| <a name="module_create_project_from_project_profile_grant"></a> [create\_project\_from\_project\_profile\_grant](#module\_create\_project\_from\_project\_profile\_grant) | ../../modules/policy-grant/create_project | n/a |
| <a name="module_domain"></a> [domain](#module\_domain) | ../.. | n/a |
| <a name="module_generative_ai_project_profile"></a> [generative\_ai\_project\_profile](#module\_generative\_ai\_project\_profile) | ../../modules/project-profile | n/a |
| <a name="module_project"></a> [project](#module\_project) | ../../modules/project | n/a |
| <a name="module_sql_analytics_project_profile"></a> [sql\_analytics\_project\_profile](#module\_sql\_analytics\_project\_profile) | ../../modules/project-profile | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_datazone_user_profile.sso_users](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/datazone_user_profile) | resource |
| [awscc_datazone_project_membership.project_membership](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/datazone_project_membership) | resource |
| [random_id.project_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_subnets.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region where the domain will be created | `string` | `"us-east-1"` | no |
| <a name="input_domain_description"></a> [domain\_description](#input\_domain\_description) | Description of the SageMaker Unified Studio domain | `string` | `"SageMaker Unified Studio domain with modular blueprint and profile setup"` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Name of the SageMaker Unified Studio domain | `string` | `"terraform-quick-setup-domain"` | no |
| <a name="input_enable_all_capabilities"></a> [enable\_all\_capabilities](#input\_enable\_all\_capabilities) | Enable the All capabilities default project profile. Enabling this will create the project profile and enable the selected blueprints. | `bool` | `true` | no |
| <a name="input_enable_generative_ai"></a> [enable\_generative\_ai](#input\_enable\_generative\_ai) | Enable the Generative AI application development default project profile. Enabling this will create the project profile and enable the selected blueprints. | `bool` | `true` | no |
| <a name="input_enable_sql_analytics"></a> [enable\_sql\_analytics](#input\_enable\_sql\_analytics) | Enable the SQL analytics default project profile. Enabling this will create the project profile and enable the selected blueprints. | `bool` | `true` | no |
| <a name="input_enable_sso"></a> [enable\_sso](#input\_enable\_sso) | Enable single sign on (SSO) using the default IAM Identity Center instance for the region | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (e.g., dev, staging, prod) | `string` | `"test"` | no |
| <a name="input_model_consumption_role_arn"></a> [model\_consumption\_role\_arn](#input\_model\_consumption\_role\_arn) | ARN of existing AmazonDataZoneBedrockFMConsumptionRole. If null, auto-created by the domain module. | `string` | `null` | no |
| <a name="input_model_management_role_arn"></a> [model\_management\_role\_arn](#input\_model\_management\_role\_arn) | ARN of existing AmazonDataZoneBedrockModelManagementRole. If null, auto-created by the domain module. | `string` | `null` | no |
| <a name="input_owner"></a> [owner](#input\_owner) | Owner of the domain (for tagging purposes) | `string` | `"terraform-quick-setup"` | no |
| <a name="input_project_description"></a> [project\_description](#input\_project\_description) | Description of the project | `string` | `"Quick-setup project created with Terraform for SageMaker Unified Studio"` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project to create | `string` | `"terraform-quick-setup-project"` | no |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | Existing S3 bucket name for Tooling blueprint storage. If null, a dedicated bucket is created by the domain module. | `string` | `null` | no |
| <a name="input_sso_users"></a> [sso\_users](#input\_sso\_users) | A list of SSO user identifiers to add as members to the created domain and project | `list(string)` | `[]` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet IDs for blueprint regional parameters. If null, subnets from the default VPC are used. | `list(string)` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_user_role_policy_arns"></a> [user\_role\_policy\_arns](#input\_user\_role\_policy\_arns) | List of IAM policy ARNs to apply as user role policies on the Tooling blueprint | `list(string)` | `null` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID for blueprint regional parameters. If null, the default VPC is used. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | AWS account ID where resources are created |
| <a name="output_blueprint_ids"></a> [blueprint\_ids](#output\_blueprint\_ids) | Map of blueprint logical names to their resolved blueprint IDs |
| <a name="output_blueprint_names"></a> [blueprint\_names](#output\_blueprint\_names) | Map of blueprint logical names to their blueprint names |
| <a name="output_domain_arn"></a> [domain\_arn](#output\_domain\_arn) | ARN of the created SageMaker Unified Studio domain |
| <a name="output_domain_execution_role_arn"></a> [domain\_execution\_role\_arn](#output\_domain\_execution\_role\_arn) | ARN of the domain execution role |
| <a name="output_domain_id"></a> [domain\_id](#output\_domain\_id) | ID of the created SageMaker Unified Studio domain |
| <a name="output_domain_name"></a> [domain\_name](#output\_domain\_name) | Name of the created SageMaker Unified Studio domain |
| <a name="output_domain_root_unit_id"></a> [domain\_root\_unit\_id](#output\_domain\_root\_unit\_id) | Root domain unit ID of the domain |
| <a name="output_domain_service_role_arn"></a> [domain\_service\_role\_arn](#output\_domain\_service\_role\_arn) | ARN of the domain service role |
| <a name="output_domain_url"></a> [domain\_url](#output\_domain\_url) | Portal URL for accessing the SageMaker Unified Studio domain |
| <a name="output_manage_access_role_arn"></a> [manage\_access\_role\_arn](#output\_manage\_access\_role\_arn) | ARN of the manage access role (from domain module) |
| <a name="output_project_id"></a> [project\_id](#output\_project\_id) | ID of the created project |
| <a name="output_project_name"></a> [project\_name](#output\_project\_name) | Name of the created project |
| <a name="output_project_profile_ids"></a> [project\_profile\_ids](#output\_project\_profile\_ids) | List of all enabled project profile IDs |
| <a name="output_project_url"></a> [project\_url](#output\_project\_url) | URL to access the project in SageMaker Unified Studio |
| <a name="output_provisioning_role_arn"></a> [provisioning\_role\_arn](#output\_provisioning\_role\_arn) | ARN of the provisioning role (from domain module) |
| <a name="output_region"></a> [region](#output\_region) | AWS region where resources are created |
| <a name="output_s3_bucket_name"></a> [s3\_bucket\_name](#output\_s3\_bucket\_name) | S3 bucket name used by the domain |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | Subnet IDs used for blueprint configurations |
| <a name="output_tooling_blueprint_id"></a> [tooling\_blueprint\_id](#output\_tooling\_blueprint\_id) | ID of the Tooling blueprint (created by the domain module) |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPC ID used for blueprint configurations |
<!-- END_TF_DOCS -->