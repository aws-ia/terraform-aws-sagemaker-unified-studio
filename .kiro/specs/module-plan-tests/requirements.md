# Requirements Document

## Introduction

This feature adds plan-only Terraform test files for each of the six modules in the terraform-aws-sagemaker-unified-studio project. The tests use `terraform test` with `command = plan` and `mock_provider` blocks to validate module configuration graphs, variable validations, and resource planning without requiring real AWS credentials or resource provisioning. This is a stepping stone toward full lifecycle testing with Terratest.

## Glossary

- **Test_Runner**: The `terraform test` command execution environment that discovers `.tftest.hcl` files and runs test blocks
- **Mock_Provider**: A `mock_provider` block in a `.tftest.hcl` file that substitutes a real Terraform provider with a no-op implementation, allowing plan and apply without credentials
- **Plan_Test**: A `run` block with `command = plan` that validates the Terraform configuration graph and planned resource changes without creating real infrastructure
- **Module_Under_Test**: One of the six Terraform modules targeted by a test file, referenced via a `module { source = "..." }` block inside a `run` block
- **Variable_Validation**: A `validation` block inside a Terraform `variable` block that enforces constraints on input values (e.g., regex patterns, length checks)
- **Test_File**: A `.tftest.hcl` file in the `tests/` directory containing `mock_provider` declarations and one or more `run` blocks
- **Blueprint_Module**: The module at `modules/blueprint` that configures a SageMaker Unified Studio environment blueprint
- **Bootstrap_Module**: The module at `modules/blueprint/bootstrap` that creates IAM roles and Lake Formation settings for blueprint configuration
- **Metadata_Form_Module**: The module at `modules/metadata_form` that creates DataZone metadata form types
- **Project_Module**: The module at `modules/project` that creates DataZone projects and manages memberships
- **Project_Profile_Module**: The module at `modules/project-profile` that creates DataZone project profiles with environment configurations
- **Policy_Grant_Module**: The module at `modules/policy-grant/create_project` that grants principals the ability to create projects from project profiles

## Requirements

### Requirement 1: Test File Organization

**User Story:** As a developer, I want each module to have a dedicated test file in the `tests/` directory, so that I can run module-level plan tests independently.

#### Acceptance Criteria

1. THE Test_Runner SHALL discover at least six Test_File files under the `tests/` directory, one for each Module_Under_Test
2. WHEN a Test_File is executed, THE Test_Runner SHALL resolve the Module_Under_Test via a `module { source = "..." }` block pointing to the relative path of the module
3. THE Test_File SHALL declare `mock_provider` blocks for every provider required by the Module_Under_Test (aws, awscc, time, null as applicable)

### Requirement 2: Plan-Only Execution

**User Story:** As a developer, I want all module tests to use `command = plan` only, so that no real infrastructure is created or destroyed during testing.

#### Acceptance Criteria

1. THE Plan_Test SHALL set `command = plan` in every `run` block across all Test_File files
2. THE Plan_Test SHALL complete successfully using only Mock_Provider blocks, without requiring AWS credentials or network access
3. THE Plan_Test SHALL validate that the Terraform configuration graph is valid and produces a non-error plan

### Requirement 3: Mock Provider Coverage

**User Story:** As a developer, I want mock providers to cover all required providers for each module, so that plan tests do not fail due to missing provider configurations.

#### Acceptance Criteria

1. WHEN the Module_Under_Test requires the `aws` provider, THE Test_File SHALL include a `mock_provider "aws" {}` block
2. WHEN the Module_Under_Test requires the `awscc` provider, THE Test_File SHALL include a `mock_provider "awscc" {}` block
3. WHEN the Module_Under_Test requires the `time` provider, THE Test_File SHALL include a `mock_provider "time" {}` block
4. WHEN the Module_Under_Test requires the `null` provider, THE Test_File SHALL include a `mock_provider "null" {}` block

### Requirement 4: Blueprint Module Test

**User Story:** As a developer, I want a plan test for the Blueprint_Module, so that I can validate its configuration graph with required and optional variables.

#### Acceptance Criteria

1. THE Test_File for Blueprint_Module SHALL provide valid values for required variables `domain_id` and `blueprint_name`
2. THE Plan_Test SHALL produce a plan that includes `aws_datazone_environment_blueprint_configuration` or `awscc_datazone_environment_blueprint_configuration` resources
3. WHEN `domain_id` is provided in the format `dzd-` followed by 1-36 alphanumeric characters, THE Plan_Test SHALL succeed without variable validation errors
4. THE Test_File for Blueprint_Module SHALL declare mock providers for `aws` and `awscc`

### Requirement 5: Bootstrap Module Test

**User Story:** As a developer, I want a plan test for the Bootstrap_Module, so that I can validate IAM role creation and Lake Formation configuration planning.

#### Acceptance Criteria

1. THE Test_File for Bootstrap_Module SHALL provide a valid `domain_id` value
2. THE Plan_Test SHALL produce a plan that includes `aws_iam_role` resources when `create_provisioning_role` and `create_manage_access_role` are set to `true`
3. THE Plan_Test SHALL produce a plan that includes `aws_lakeformation_data_lake_settings` when `configure_lake_formation` is set to `true`
4. THE Test_File for Bootstrap_Module SHALL declare a mock provider for `aws`
5. WHEN `create_provisioning_role` is set to `false`, THE Plan_Test SHALL produce a plan that excludes `aws_iam_role.sagemaker_provisioning`

### Requirement 6: Metadata Form Module Test

**User Story:** As a developer, I want a plan test for the Metadata_Form_Module, so that I can validate form type creation and field validation logic.

#### Acceptance Criteria

1. THE Test_File for Metadata_Form_Module SHALL provide valid values for required variables `domain_identifier`, `owning_project_identifier`, `technical_name`, and `fields`
2. THE Plan_Test SHALL produce a plan that includes an `aws_datazone_form_type` resource
3. THE `fields` variable SHALL include at least one field object with valid `technical_name` and `field_type` values
4. THE Test_File for Metadata_Form_Module SHALL declare mock providers for `aws` and `awscc`

### Requirement 7: Project Module Test

**User Story:** As a developer, I want a plan test for the Project_Module, so that I can validate project creation and membership planning.

#### Acceptance Criteria

1. THE Test_File for Project_Module SHALL provide valid values for required variables `domain_id` and `project_name`
2. THE Plan_Test SHALL produce a plan that includes an `awscc_datazone_project` resource
3. WHEN `user_list` contains user identifiers, THE Plan_Test SHALL produce a plan that includes `awscc_datazone_project_membership` resources
4. THE Test_File for Project_Module SHALL declare mock providers for `aws` and `null`

### Requirement 8: Project Profile Module Test

**User Story:** As a developer, I want a plan test for the Project_Profile_Module, so that I can validate project profile creation with environment configurations.

#### Acceptance Criteria

1. THE Test_File for Project_Profile_Module SHALL provide valid values for required variables `domain_id`, `name`, and `blueprints`
2. THE `blueprints` variable SHALL include at least a `Tooling` entry as required by the module logic
3. THE Plan_Test SHALL produce a plan that includes an `awscc_datazone_project_profile` resource
4. THE Test_File for Project_Profile_Module SHALL declare mock providers for `aws` and `awscc`

### Requirement 9: Policy Grant Module Test

**User Story:** As a developer, I want a plan test for the Policy_Grant_Module, so that I can validate policy grant creation for domain unit principals.

#### Acceptance Criteria

1. THE Test_File for Policy_Grant_Module SHALL provide valid values for required variables `domain_id`, `domain_unit_id`, and `project_profile_ids`
2. THE Plan_Test SHALL produce a plan that includes `awscc_datazone_policy_grant` resources
3. WHEN `all_users` is set to `true`, THE Plan_Test SHALL produce a plan with a single policy grant using the `all_users_grant_filter`
4. THE Test_File for Policy_Grant_Module SHALL declare mock providers for `aws` and `awscc`

### Requirement 10: Variable Validation Testing

**User Story:** As a developer, I want tests to verify that variable validation rules reject invalid inputs, so that I can confirm modules fail fast on bad configuration.

#### Acceptance Criteria

1. WHEN `domain_id` is provided in an invalid format (not matching `dzd[-_][a-zA-Z0-9_-]{1,36}`), THE Plan_Test SHALL fail with a variable validation error
2. WHEN `project_profile_ids` is provided as an empty list to the Policy_Grant_Module, THE Plan_Test SHALL fail with a validation error stating at least one profile ID is required
3. WHEN a `fields` entry in the Metadata_Form_Module has an invalid `field_type`, THE Plan_Test SHALL fail with a validation error listing the allowed types
4. WHEN `project_name` exceeds 64 characters in the Project_Module, THE Plan_Test SHALL fail with a validation error

### Requirement 11: Test Consistency with Existing Pattern

**User Story:** As a developer, I want the new module tests to follow the same conventions as the existing `01_mandatory.tftest.hcl` test, so that the test suite is consistent and maintainable.

#### Acceptance Criteria

1. THE Test_File SHALL use the same `mock_provider` block syntax as the existing `tests/01_mandatory.tftest.hcl` file
2. THE Test_File SHALL use the `module { source = "..." }` block pattern to target specific modules
3. THE Test_File SHALL use the `variables { }` block inside `run` blocks to pass input values to the Module_Under_Test
