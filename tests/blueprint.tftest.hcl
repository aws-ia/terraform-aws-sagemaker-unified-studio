#####################################################################################
# Singular Blueprint Module Tests
# All tests use command = plan — nothing is created in your AWS account.
#####################################################################################

#####################################################################################
# Scenario 1: Blueprint WITH regional parameters (e.g., DataLake)
# Default behavior — has_regional_parameters = true, all 3 params provided
#####################################################################################

run "blueprint_with_regional_params" {
  command = plan

  module {
    source = "./modules/blueprint"
  }

  override_data {
    target = data.aws_iam_roles.provisioning_role
    values = { arns = [], names = [] }
  }

  override_data {
    target = data.aws_iam_roles.manage_access_role
    values = { arns = [], names = [] }
  }

  override_data {
    target = data.aws_datazone_environment_blueprint.this
    values = { id = "mock-datalake-bp-id" }
  }

  override_data {
    target = data.aws_subnet.validation["subnet-abc123"]
    values = { id = "subnet-abc123", vpc_id = "vpc-abc123" }
  }

  variables {
    domain_id           = "dzd-test123456"
    blueprint_name      = "DataLake"
    domain_root_unit_id = "root-unit-123"
    vpc_id              = "vpc-abc123"
    subnet_ids          = ["subnet-abc123"]
    s3_bucket_name      = "test-bucket-123"
  }

  # Blueprint config should be created
  assert {
    condition     = aws_datazone_environment_blueprint_configuration.this.domain_id == "dzd-test123456"
    error_message = "Blueprint config should use the provided domain_id"
  }

  # Regional parameters should be set
  assert {
    condition     = aws_datazone_environment_blueprint_configuration.this.regional_parameters != null
    error_message = "Regional parameters should be set when has_regional_parameters is true"
  }

  # IAM roles should be created (fresh account)
  assert {
    condition     = length(aws_iam_role.sagemaker_provisioning) == 1
    error_message = "Provisioning role should be created when not provided"
  }

  assert {
    condition     = length(aws_iam_role.sagemaker_manage_access) == 1
    error_message = "ManageAccess role should be created when not provided"
  }

  # Policy grant should be created
  assert {
    condition     = awscc_datazone_policy_grant.this.policy_type == "CREATE_ENVIRONMENT_FROM_BLUEPRINT"
    error_message = "Policy grant should have correct policy type"
  }

  # Outputs
  assert {
    condition     = output.blueprint_id == "mock-datalake-bp-id"
    error_message = "Output blueprint_id should match data source"
  }

  assert {
    condition     = output.blueprint_name == "DataLake"
    error_message = "Output blueprint_name should match input"
  }

  assert {
    condition     = output.provisioning_role_created == true
    error_message = "Output should indicate provisioning role was created"
  }

  assert {
    condition     = output.manage_access_role_created == true
    error_message = "Output should indicate manage access role was created"
  }
}

#####################################################################################
# Scenario 2: Blueprint WITHOUT regional parameters (e.g., QuickSight)
# has_regional_parameters = false, no VPC/S3/subnets needed
#####################################################################################

run "blueprint_without_regional_params" {
  command = plan

  module {
    source = "./modules/blueprint"
  }

  override_data {
    target = data.aws_iam_roles.provisioning_role
    values = { arns = [], names = [] }
  }

  override_data {
    target = data.aws_iam_roles.manage_access_role
    values = { arns = [], names = [] }
  }

  override_data {
    target = data.aws_datazone_environment_blueprint.this
    values = { id = "mock-quicksight-bp-id" }
  }

  variables {
    domain_id               = "dzd-test123456"
    blueprint_name          = "QuickSight"
    domain_root_unit_id     = "root-unit-123"
    has_regional_parameters = false
  }

  # Blueprint config should be created
  assert {
    condition     = aws_datazone_environment_blueprint_configuration.this.domain_id == "dzd-test123456"
    error_message = "Blueprint config should use the provided domain_id"
  }

  # Regional parameters should be null
  assert {
    condition     = aws_datazone_environment_blueprint_configuration.this.regional_parameters == null
    error_message = "Regional parameters should be null when has_regional_parameters is false"
  }

  # No subnet validation should run
  assert {
    condition     = length(data.aws_subnet.validation) == 0
    error_message = "No subnet validation should run when has_regional_parameters is false"
  }

  assert {
    condition     = output.blueprint_name == "QuickSight"
    error_message = "Output blueprint_name should match input"
  }
}

#####################################################################################
# Scenario 3: User provides existing IAM roles
# Expected: No roles created, user ARNs used
#####################################################################################

run "blueprint_user_provides_roles" {
  command = plan

  module {
    source = "./modules/blueprint"
  }

  override_data {
    target = data.aws_datazone_environment_blueprint.this
    values = { id = "mock-redshift-bp-id" }
  }

  override_data {
    target = data.aws_subnet.validation["subnet-abc123"]
    values = { id = "subnet-abc123", vpc_id = "vpc-abc123" }
  }

  variables {
    domain_id              = "dzd-test123456"
    blueprint_name         = "RedshiftServerless"
    domain_root_unit_id    = "root-unit-123"
    vpc_id                 = "vpc-abc123"
    subnet_ids             = ["subnet-abc123"]
    s3_bucket_name         = "test-bucket-123"
    manage_access_role_arn = "arn:aws:iam::123456789012:role/MyManageAccess"
    provisioning_role_arn  = "arn:aws:iam::123456789012:role/MyProvisioning"
  }

  assert {
    condition     = length(aws_iam_role.sagemaker_provisioning) == 0
    error_message = "Provisioning role should NOT be created when user provides ARN"
  }

  assert {
    condition     = length(aws_iam_role.sagemaker_manage_access) == 0
    error_message = "ManageAccess role should NOT be created when user provides ARN"
  }

  assert {
    condition     = length(aws_iam_policy.sagemaker_manage_access_redshift) == 0
    error_message = "Custom policy should NOT be created when user provides manage access ARN"
  }

  assert {
    condition     = output.provisioning_role_created == false
    error_message = "Output should indicate provisioning role was not created"
  }

  assert {
    condition     = output.manage_access_role_created == false
    error_message = "Output should indicate manage access role was not created"
  }

  assert {
    condition     = output.manage_access_role_arn == "arn:aws:iam::123456789012:role/MyManageAccess"
    error_message = "Output should reflect user-provided manage access role ARN"
  }

  assert {
    condition     = output.provisioning_role_arn == "arn:aws:iam::123456789012:role/MyProvisioning"
    error_message = "Output should reflect user-provided provisioning role ARN"
  }
}

#####################################################################################
# Scenario 5: Custom enabled regions
# Expected: Blueprint enabled in specified regions
#####################################################################################

run "blueprint_custom_regions" {
  command = plan

  module {
    source = "./modules/blueprint"
  }

  override_data {
    target = data.aws_iam_roles.provisioning_role
    values = { arns = [], names = [] }
  }

  override_data {
    target = data.aws_iam_roles.manage_access_role
    values = { arns = [], names = [] }
  }

  override_data {
    target = data.aws_datazone_environment_blueprint.this
    values = { id = "mock-emr-bp-id" }
  }

  override_data {
    target = data.aws_subnet.validation["subnet-abc123"]
    values = { id = "subnet-abc123", vpc_id = "vpc-abc123" }
  }

  variables {
    domain_id           = "dzd-test123456"
    blueprint_name      = "EmrServerless"
    domain_root_unit_id = "root-unit-123"
    vpc_id              = "vpc-abc123"
    subnet_ids          = ["subnet-abc123"]
    s3_bucket_name      = "test-bucket-123"
    enabled_regions     = ["us-east-1", "us-west-2"]
  }

  assert {
    condition     = length(output.enabled_regions) == 2
    error_message = "Should have 2 enabled regions"
  }

  assert {
    condition     = contains(output.enabled_regions, "us-east-1") && contains(output.enabled_regions, "us-west-2")
    error_message = "Enabled regions should contain us-east-1 and us-west-2"
  }
}
