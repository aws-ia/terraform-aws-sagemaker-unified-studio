#####################################################################################
# IAM Role Existence Validation and Creation Tests (R4)
# All tests use command = plan — nothing is created in your AWS account.
#
# Tests use module { source = "./" } which gives direct access to all root module
# resources (e.g., aws_iam_role.domain_execution from main.tf).
#
# Domain tests: validate conditional logic for DomainExecution and DomainService roles
# Blueprint tests: require a real domain_id (skipped if not available)
#####################################################################################

#####################################################################################
# Scenario 1: Fresh account - no roles exist, no ARNs provided
# Uses override_data to simulate empty data source results (no existing roles),
# ensuring the creation path is deterministically tested regardless of account state.
#####################################################################################

# Mock data sources to return empty results (fresh account)
override_data {
  target = data.aws_iam_roles.domain_execution_role
  values = {
    arns  = []
    names = []
  }
}

override_data {
  target = data.aws_iam_roles.domain_service_role
  values = {
    arns  = []
    names = []
  }
}

override_data {
  target = data.aws_iam_roles.provisioning_role
  values = {
    arns  = []
    names = []
  }
}

run "domain_no_roles_provided" {
  command = plan
  module {
    source = "./"
  }

  variables {
    domain_name               = "test-domain-fresh"
    domain_execution_role_arn = null
    domain_service_role_arn   = null
    vpc_id                    = "vpc-abc123"
    subnet_ids                = ["subnet-abc123"]
    s3_bucket_name            = "test-bucket-fresh"
  }

  # Roles MUST be created (data sources return empty)
  assert {
    condition     = length(aws_iam_role.domain_execution) == 1
    error_message = "Domain execution role should be created when it doesn't exist"
  }

  assert {
    condition     = length(aws_iam_role.domain_service) == 1
    error_message = "Domain service role should be created when it doesn't exist"
  }

  # Outputs should reflect creation
  assert {
    condition     = output.domain_execution_role_created == true
    error_message = "Output should indicate domain execution role was created"
  }

  assert {
    condition     = output.domain_service_role_created == true
    error_message = "Output should indicate domain service role was created"
  }

  # Policy attachments must match role creation
  assert {
    condition     = length(aws_iam_role_policy_attachment.domain_execution_policy) == 1
    error_message = "Domain execution policy should be attached when role is created"
  }

  assert {
    condition     = length(aws_iam_role_policy_attachment.domain_service_policy) == 1
    error_message = "Domain service policy should be attached when role is created"
  }
}

#####################################################################################
# Scenario 2: User provides both domain roles
# Expected: No domain roles created, user ARNs used directly
#####################################################################################

run "domain_user_provides_both_roles" {
  command = plan
  module {
    source = "./"
  }

  variables {
    domain_name               = "test-domain-provided"
    domain_execution_role_arn = "arn:aws:iam::123456789012:role/MyCustomExecutionRole"
    domain_service_role_arn   = "arn:aws:iam::123456789012:role/MyCustomServiceRole"
    vpc_id                    = "vpc-abc123"
    subnet_ids                = ["subnet-abc123"]
    s3_bucket_name            = "test-bucket-provided"
  }

  # No roles should be created
  assert {
    condition     = length(aws_iam_role.domain_execution) == 0
    error_message = "Domain execution role should NOT be created when user provides ARN"
  }

  assert {
    condition     = length(aws_iam_role.domain_service) == 0
    error_message = "Domain service role should NOT be created when user provides ARN"
  }

  # Domain should use the provided ARNs
  assert {
    condition     = aws_datazone_domain.main.domain_execution_role == "arn:aws:iam::123456789012:role/MyCustomExecutionRole"
    error_message = "Domain should use user-provided execution role ARN"
  }

  assert {
    condition     = aws_datazone_domain.main.service_role == "arn:aws:iam::123456789012:role/MyCustomServiceRole"
    error_message = "Domain should use user-provided service role ARN"
  }

  # Outputs should indicate roles were NOT created
  assert {
    condition     = output.domain_execution_role_created == false
    error_message = "Output should indicate domain execution role was not created"
  }

  assert {
    condition     = output.domain_service_role_created == false
    error_message = "Output should indicate domain service role was not created"
  }

  # No policies should be attached
  assert {
    condition     = length(aws_iam_role_policy_attachment.domain_execution_policy) == 0
    error_message = "No execution policy should be attached when user provides ARN"
  }

  assert {
    condition     = length(aws_iam_role_policy_attachment.domain_service_policy) == 0
    error_message = "No service policy should be attached when user provides ARN"
  }
}

#####################################################################################
# Blueprint IAM role tests (Provisioning + ManageAccess)
# All tests use command = plan — nothing is created.
# Environment blueprint data sources are mocked via override_data so tests
# don't require DataZone domain membership (ListEnvironmentBlueprints permission).
#####################################################################################

provider "aws" {
  alias  = "us_east_2"
  region = "us-east-2"
}

#####################################################################################
# Scenario 5: Blueprint - fresh account, no roles exist, no ARNs provided
# Uses override_data to simulate empty data source results (no existing roles),
# ensuring the creation path is deterministically tested.
#####################################################################################

run "blueprint_no_roles_provided" {
  command = plan

  providers = {
    aws = aws.us_east_2
  }

  module {
    source = "./modules/blueprints"
  }

  # Mock IAM data sources to return empty results (fresh account)
  override_data {
    target = data.aws_iam_roles.provisioning_role
    values = {
      arns  = []
      names = []
    }
  }

  override_data {
    target = data.aws_iam_roles.manage_access_role
    values = {
      arns  = []
      names = []
    }
  }

  # Mock environment blueprint data sources to avoid ListEnvironmentBlueprints permission
  override_data {
    target = data.aws_datazone_environment_blueprint.default_data_lake
    values = { id = "mock-datalake-bp-id" }
  }

  override_data {
    target = data.aws_datazone_environment_blueprint.LakehouseCatalog
    values = { id = "mock-lakehouse-bp-id" }
  }

  override_data {
    target = data.aws_datazone_environment_blueprint.Tooling
    values = { id = "mock-tooling-bp-id" }
  }

  override_data {
    target = data.aws_datazone_environment_blueprint.RedshiftServerless
    values = { id = "mock-redshift-bp-id" }
  }

  override_data {
    target = data.aws_datazone_environment_blueprint.MLExperiments
    values = { id = "mock-ml-bp-id" }
  }

  variables {
    domain_id                 = "dzd-example123456"
    domain_root_unit_id       = "dzd-example123456"
    manage_access_role_arn    = null
    provisioning_role_arn     = null
    s3_bucket_name            = "test-bucket-123"
    vpc_id                    = "vpc-abc123"
    subnet_ids                = ["subnet-abc123"]
    domain_execution_role_arn = "arn:aws:iam::123456789012:role/service-role/AmazonSageMakerDomainExecution"
  }

  # Roles MUST be created (data sources return empty)
  assert {
    condition     = length(aws_iam_role.sagemaker_provisioning) == 1
    error_message = "Provisioning role should be created when it doesn't exist"
  }

  assert {
    condition     = length(aws_iam_role.sagemaker_manage_access) == 1
    error_message = "Manage access role should be created when it doesn't exist"
  }

  # Outputs should reflect creation
  assert {
    condition     = output.sagemaker_provisioning_role_created == true
    error_message = "Output should indicate provisioning role was created"
  }

  assert {
    condition     = output.sagemaker_manage_access_role_created == true
    error_message = "Output should indicate manage access role was created"
  }

  # All policy attachments must be created
  assert {
    condition     = length(aws_iam_role_policy_attachment.sagemaker_provisioning) == 1
    error_message = "Provisioning policy should be attached when role is created"
  }

  assert {
    condition     = length(aws_iam_role_policy_attachment.sagemaker_manage_access) == 1
    error_message = "SageMaker manage access policy should be attached when role is created"
  }

  assert {
    condition     = length(aws_iam_role_policy_attachment.glue_manage_access) == 1
    error_message = "Glue manage access policy should be attached when role is created"
  }

  assert {
    condition     = length(aws_iam_role_policy_attachment.redshift_manage_access) == 1
    error_message = "Redshift manage access policy should be attached when role is created"
  }

  assert {
    condition     = length(aws_iam_policy.sagemaker_manage_access_redshift) == 1
    error_message = "Customer managed policy should be created when role is created"
  }
}

#####################################################################################
# Scenario 6: Blueprint - user provides both roles
# Expected: No roles created
#####################################################################################

run "blueprint_user_provides_both_roles" {
  command = plan

  providers = {
    aws = aws.us_east_2
  }

  module {
    source = "./modules/blueprints"
  }

  # Mock environment blueprint data sources to avoid ListEnvironmentBlueprints permission
  override_data {
    target = data.aws_datazone_environment_blueprint.default_data_lake
    values = { id = "mock-datalake-bp-id" }
  }

  override_data {
    target = data.aws_datazone_environment_blueprint.LakehouseCatalog
    values = { id = "mock-lakehouse-bp-id" }
  }

  override_data {
    target = data.aws_datazone_environment_blueprint.Tooling
    values = { id = "mock-tooling-bp-id" }
  }

  override_data {
    target = data.aws_datazone_environment_blueprint.RedshiftServerless
    values = { id = "mock-redshift-bp-id" }
  }

  override_data {
    target = data.aws_datazone_environment_blueprint.MLExperiments
    values = { id = "mock-ml-bp-id" }
  }

  variables {
    domain_id                 = "dzd-example123456"
    domain_root_unit_id       = "dzd-example123456"
    manage_access_role_arn    = "arn:aws:iam::123456789012:role/MyCustomManageAccess"
    provisioning_role_arn     = "arn:aws:iam::123456789012:role/MyCustomProvisioning"
    s3_bucket_name            = "test-bucket-456"
    vpc_id                    = "vpc-def456"
    subnet_ids                = ["subnet-def456"]
    domain_execution_role_arn = "arn:aws:iam::123456789012:role/service-role/AmazonSageMakerDomainExecution"
  }

  assert {
    condition     = length(aws_iam_role.sagemaker_manage_access) == 0
    error_message = "Manage access role should NOT be created when user provides ARN"
  }

  assert {
    condition     = length(aws_iam_role.sagemaker_provisioning) == 0
    error_message = "Provisioning role should NOT be created when user provides ARN"
  }

  assert {
    condition     = length(aws_iam_policy.sagemaker_manage_access_redshift) == 0
    error_message = "Customer managed policy should NOT be created when user provides manage access ARN"
  }

  assert {
    condition     = output.sagemaker_provisioning_role_created == false
    error_message = "Output should indicate provisioning role was not created"
  }

  assert {
    condition     = output.sagemaker_manage_access_role_created == false
    error_message = "Output should indicate manage access role was not created"
  }
}


