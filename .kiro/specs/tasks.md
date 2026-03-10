# Implementation Plan: SageMaker Studio Refactoring

## Overview

Refactor the SageMaker Unified Studio Terraform module from a monolithic architecture to a modular, composable architecture. The implementation proceeds in phases: domain module enhancements (IAM roles, Tooling blueprint, S3, model governance), blueprint module singularization, project profile module singularization, quick-setup example modernization, and testing.

## Tasks

- [ ] 1. Refactor Domain Module — IAM role auto-creation and optional ARN inputs
  - [ ] 1.1 Add new variables to `variables.tf` for `model_management_role_arn`, `model_consumption_role_arn`, `vpc_id`, `subnet_ids`, `s3_bucket_name`, and `user_role_policy_arn` with validation blocks
    - Add `model_management_role_arn` (optional string), `model_consumption_role_arn` (optional string), `vpc_id` (required, regex `^vpc-[a-z0-9]+$`), `subnet_ids` (required list, regex `^subnet-[a-z0-9]+$`), `s3_bucket_name` (optional string), `user_role_policy_arn` (optional string, IAM policy ARN format validation)
    - _Requirements: 3.5, 5.1, 5.2, 5.6, 5.7, 6.1, 7.1, 8.1, 8.4_

  - [ ] 1.2 Implement conditional IAM role resources in `main.tf` for DomainExecution, DomainService, ModelManagement, and ModelConsumption roles
    - Create `aws_iam_role.domain_execution` with count conditional on `domain_execution_role_arn == null`, trust policy for `datazone.amazonaws.com`, attach `SageMakerStudioDomainExecutionRolePolicy`
    - Create `aws_iam_role.domain_service` with same conditional pattern, attach `SageMakerStudioDomainServiceRolePolicy`
    - Create `aws_iam_role.model_management` for `AmazonDataZoneBedrockModelManagementRole`, attach `AmazonDataZoneBedrockModelManagementPolicy`
    - Create `aws_iam_role.model_consumption` for `AmazonDataZoneBedrockFMConsumptionRole`, attach `AmazonDataZoneBedrockModelConsumptionPolicy`
    - Add locals block to resolve each role ARN: use provided ARN or created role ARN
    - Ensure IAM roles are created before the domain resource via `depends_on`
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 6.2, 7.2_

  - [ ]* 1.3 Write property test for conditional IAM role creation (Go + rapid)
    - **Property 3: Conditional IAM role creation** — role created iff ARN is null
    - **Validates: Requirements 1.6, 4.1, 4.2, 6.2, 7.2**

- [ ] 2. Refactor Domain Module — Tooling blueprint, S3 bucket, and model governance
  - [ ] 2.1 Implement optional S3 bucket creation in `main.tf`
    - Create `aws_s3_bucket.domain` with count conditional on `var.s3_bucket_name == null`
    - Add `aws_s3_bucket_server_side_encryption_configuration` and `aws_s3_bucket_public_access_block` for the created bucket
    - Add local `s3_bucket_name` that resolves to provided name or created bucket ID
    - _Requirements: 3.7_

  - [ ] 2.2 Implement Tooling blueprint configuration using awscc provider in `main.tf`
    - Add `data.aws_datazone_environment_blueprint.tooling` data source to look up Tooling blueprint ID by name
    - Create `awscc_datazone_environment_blueprint_configuration.tooling` with `global_parameters` for `QueryExecutionRoleArn` and conditional `UserRolePolicyArn`
    - Configure `regional_parameters` with VPC, subnets, and S3 location
    - Add `depends_on` to ensure domain is created first
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 8.2, 8.3_

  - [ ] 2.3 Implement model governance project profile and project in `main.tf`
    - Create `awscc_datazone_project_profile.model_governance_project_profile` with zero environment configurations
    - Create `awscc_datazone_project.model_governance_project` linked to the profile
    - Use `model_management_role_arn` in the governance project configuration
    - _Requirements: 6.4_

  - [ ] 2.4 Update `outputs.tf` with new domain module outputs
    - Add outputs: `tooling_blueprint_id`, `domain_service_role_arn`, `model_management_role_arn`, `model_consumption_role_arn`, `s3_bucket_name`
    - _Requirements: 3.4, 4.4, 6.4_

  - [ ]* 2.5 Write property test for S3 bucket conditional creation (Go + rapid)
    - **Property 6: S3 bucket conditional creation**
    - **Validates: Requirements 3.7**

  - [ ]* 2.6 Write property test for user role policy on Tooling blueprint (Go + rapid)
    - **Property 7: User role policy applied to Tooling blueprint**
    - **Validates: Requirements 8.2**

- [ ] 3. Checkpoint — Domain module refactoring
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 4. Create singular Blueprint Module (`modules/blueprint/`)
  - [ ] 4.1 Create `modules/blueprint/variables.tf` with all input variables
    - Define `domain_id` (string, regex validation `^dzd[-_][a-zA-Z0-9_-]{1,36}$`), `blueprint_name` (string, `contains()` validation against supported blueprint names list), `vpc_id` (string, regex `^vpc-[a-z0-9]+$`), `subnet_ids` (list(string), non-empty, regex `^subnet-[a-z0-9]+$`), `s3_bucket_name` (string), `domain_root_unit_id` (string), `manage_access_role_arn` (optional string, auto-created if null), `provisioning_role_arn` (optional string, auto-created if null), `allow_replace_existing` (bool, default false), `enabled_regions` (optional list(string)), `configure_lake_formation` (bool, default true), `domain_execution_role_arn` (optional string), `tags` (map(string))
    - _Requirements: 1.1, 1.3, 1.6, 1.8, 1.9, 1.10, 5.1, 5.2, 5.6, 5.7_

  - [ ] 4.2 Create `modules/blueprint/main.tf` with data lookups, validation, and single blueprint configuration
    - Add `data.aws_datazone_environment_blueprint.this` to resolve blueprint ID from `blueprint_name`
    - Add `data.awscc_datazone_domain.this` to look up domain details
    - Add `data.aws_subnet.validation` for_each on `subnet_ids` to validate VPC membership
    - Add `terraform_data.subnet_vpc_validation` with precondition checking `each.value.vpc_id == var.vpc_id`
    - Create `aws_datazone_environment_blueprint_configuration.this` — single blueprint resource with `regional_parameters` built from vpc_id, subnet_ids, s3_bucket_name
    - Create `awscc_datazone_policy_grant.this` for `CREATE_ENVIRONMENT_FROM_BLUEPRINT` permission to root domain unit with child domain units
    - _Requirements: 1.1, 1.2, 1.4, 1.5, 1.6, 1.11, 5.3, 5.4, 5.5, 5.8_

  - [ ] 4.3 Implement conditional IAM role creation in `modules/blueprint/main.tf` for ManageAccess and Provisioning roles
    - Create `aws_iam_role.manage_access` with count conditional on `manage_access_role_arn == null`, name pattern `AmazonSageMakerManageAccess-<region>-<domainId>`, attach Glue/Redshift/SageMaker managed policies
    - Resolve `provisioning_role_arn` local with default name pattern `AmazonSageMakerProvisioning-<accountId>`
    - _Requirements: 1.6_

  - [ ] 4.4 Create `modules/blueprint/outputs.tf` with blueprint_id, blueprint_name, entity_id, manage_access_role_arn, provisioning_role_arn
    - _Requirements: 1.7_

  - [ ] 4.5 Create `modules/blueprint/versions.tf` with required providers (aws >= 6.28.0, awscc >= 1.68.0)
    - _Requirements: 1.7_

  - [ ]* 4.6 Write property tests for VPC ID and Subnet ID format validation (Go + rapid)
    - **Property 1: VPC ID format validation**
    - **Property 2: Subnet ID format validation**
    - **Validates: Requirements 1.9, 1.10, 5.6, 5.7**

  - [ ]* 4.7 Write property test for blueprint name validation (Go + rapid)
    - **Property 9: Blueprint name validation**
    - **Validates: Requirements 1.1**

  - [ ]* 4.8 Write property test for regional parameters include VPC and subnet configuration (Go + rapid)
    - **Property 4: Regional parameters include VPC and subnet configuration**
    - **Validates: Requirements 5.3, 5.4**

- [ ] 5. Checkpoint — Blueprint module singularization
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 6. Create singular Project Profile Module (`modules/project-profile/`)
  - [ ] 6.1 Create `modules/project-profile/variables.tf` with all input variables
    - Define `domain_id` (string, regex validation), `profile_name` (string, 1-64 chars), `blueprints` (map of objects with `blueprint_name`, `deployment_mode`, `default_parameters`, `editable_parameters`), `aws_account_id` (optional string), `aws_region` (optional string), `status` (string, default "ENABLED")
    - Add validation: `deployment_mode` must be `ON_CREATE` or `ON_DEMAND`; `blueprint_name` must be in supported list (including "Tooling")
    - _Requirements: 2.1, 2.3_

  - [ ] 6.2 Create `modules/project-profile/main.tf` with Tooling lookup, blueprint data lookups, and project profile resource
    - Add `data.aws_datazone_environment_blueprint.tooling` to look up Tooling blueprint (must exist, fails if not configured)
    - Add `data.awscc_datazone_domain.this` for `root_domain_unit_id`
    - Add `data.aws_datazone_environment_blueprint.blueprints` for_each on non-Tooling entries to resolve blueprint IDs by name
    - Build `local.environment_configurations`: Tooling always first (deployment_order=1, ON_CREATE, from data lookup), then remaining blueprints sorted by key with deployment_order starting at 2
    - Filter out any user-specified Tooling entry from the blueprints dictionary
    - Create `awscc_datazone_project_profile.this` with the built environment_configurations
    - _Requirements: 2.1, 2.2, 2.4, 2.5, 2.6_

  - [ ] 6.3 Create `modules/project-profile/outputs.tf` with project_profile_id, profile_name, environment_count
    - _Requirements: 2.2_

  - [ ] 6.4 Create `modules/project-profile/versions.tf` with required providers
    - _Requirements: 2.2_

  - [ ]* 6.5 Write property test for Tooling blueprint always first in project profile (Go + rapid)
    - **Property 5: Tooling blueprint is always first in project profile**
    - **Validates: Requirements 2.4, 2.6**

- [ ] 7. Checkpoint — Project profile module singularization
  - Ensure all tests pass, ask the user if questions arise.

- [x] 8. Modernize Quick-Setup Example (`examples/quick-setup/`)
  - [x] 8.1 Rewrite `examples/quick-setup/main.tf` to use the new modular architecture
    - Invoke the root domain module with VPC/subnet parameters, S3 bucket, user role policy ARN
    - Invoke `modules/blueprint` multiple times (e.g., for LakehouseCatalog, MLExperiments, RedshiftServerless) using `for_each` or explicit module blocks
    - Invoke `modules/project-profile` with a dictionary of blueprints referencing the blueprint module outputs
    - Demonstrate Tooling blueprint integration from the domain module output
    - Demonstrate model provisioning and consumption role configuration
    - Maintain S3 cleanup functionality on destroy
    - Maintain SSO user and project membership functionality
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 9.6, 9.7, 9.8_

  - [x] 8.2 Update `examples/quick-setup/variables.tf` with new input variables matching the modular approach
    - Add variables for VPC, subnets, S3 bucket, user role policy, model role ARNs, blueprint selection
    - _Requirements: 9.4, 9.5, 9.6_

  - [x] 8.3 Update `examples/quick-setup/outputs.tf` to expose domain, blueprint, and profile outputs
    - _Requirements: 9.3_

  - [x] 8.4 Update `examples/quick-setup/versions.tf` to match root module provider requirements
    - _Requirements: 9.1_

- [ ] 9. Checkpoint — Quick-setup example modernization
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 10. Implement Terraform test framework tests
  - [ ] 10.1 Create `tests/domain.tftest.hcl` with plan and apply test runs for the domain module
    - Plan test: verify domain creation, IAM role conditional creation (auto-created when ARN null), Tooling blueprint, S3 bucket, model governance resources
    - Apply test: verify end-to-end domain creation against real AWS account
    - Include `expect_failures` tests for invalid VPC format, invalid subnet format, invalid user role policy ARN format
    - _Requirements: 10.1, 10.2_

  - [ ] 10.2 Create `tests/blueprint.tftest.hcl` with plan and apply test runs for the singular blueprint module
    - Plan test: verify single blueprint configuration, policy grant, IAM role creation when ARN not provided
    - Apply test: verify end-to-end blueprint creation
    - Include `expect_failures` tests for invalid `blueprint_name`, invalid `vpc_id`, invalid `subnet_ids`
    - _Requirements: 10.1, 10.2_

  - [ ] 10.3 Create `tests/project_profile.tftest.hcl` with plan and apply test runs for the singular project profile module
    - Plan test: verify project profile creation, Tooling always first, blueprint dictionary handling
    - Apply test: verify end-to-end profile creation
    - _Requirements: 10.1, 10.2_

  - [ ] 10.4 Update `tests/examples.tftest.hcl` with plan test for the modernized quick-setup example
    - Plan test: verify the quick-setup example plans successfully with the new modular architecture
    - _Requirements: 10.1_

- [ ] 11. Implement Go property-based tests
  - [ ] 11.1 Create `tests/properties/` directory and `validation_test.go` with property-based tests using `pgregory.net/rapid`
    - Implement `TestVpcIdValidation` — Property 1: valid vpc-xxx strings accepted, invalid strings rejected (100+ iterations)
    - Implement `TestSubnetIdValidation` — Property 2: valid subnet-xxx lists accepted, invalid strings rejected (100+ iterations)
    - Implement `TestConditionalRoleCreation` — Property 3: role created iff ARN is null (100+ iterations)
    - Implement `TestRegionalParametersVpcSubnet` — Property 4: regional_parameters contain correct VPC and subnet values (100+ iterations)
    - Implement `TestToolingAlwaysFirst` — Property 5: Tooling is always first in environment_configurations (100+ iterations)
    - Implement `TestUserRolePolicyArnValidation` — Property 8: valid IAM policy ARN format accepted, invalid rejected (100+ iterations)
    - Implement `TestBlueprintNameValidation` — Property 9: only supported blueprint names accepted (100+ iterations)
    - _Requirements: 10.1_

  - [ ] 11.2 Create `tests/integration/full_stack_test.go` with end-to-end apply tests using terratest
    - Test full stack: domain → blueprints → project profile creation and destruction
    - Verify outputs match expected values
    - _Requirements: 10.2_

  - [ ] 11.3 Create `tests/properties/go.mod` and `tests/integration/go.mod` with required Go module dependencies
    - Add dependencies: `github.com/gruntwork-io/terratest`, `pgregory.net/rapid`, `github.com/stretchr/testify`
    - _Requirements: 10.1, 10.2_

- [ ] 12. Final checkpoint — All tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties from the design document (9 properties, renumbered after removing the old create_roles validation property)
- Unit tests validate specific examples and edge cases
- The `aws` provider is preferred; `awscc` is used only for `global_parameters`, project profiles, policy grants, and domain data source
- The old `modules/blueprints/` (plural) and `modules/project-profiles/` (plural) directories remain until migration is complete; new modules are `modules/blueprint/` (singular) and `modules/project-profile/` (singular)
- IAM roles are auto-created when the corresponding ARN input is null; no separate toggle is needed
