#####################################################################################
# IAM Role Existence Validation and Creation Tests (R4)
# All tests use command = plan — nothing is created in your AWS account.
#
# Domain tests: validate conditional logic for DomainExecution and DomainService roles
# Blueprint tests: require a real domain_id (skipped if not available)
#####################################################################################

#####################################################################################
# Scenario 1: Fresh account - no roles provided
# The data source checks if roles exist. If they do, count=0 (skip creation).
# If they don't, count=1 (create). We validate the logic is consistent.
#####################################################################################

run "domain_no_roles_provided_logic_consistent" {
  command = plan
  module {
    source = "./"
  }

  variables {
    domain_name               = "test-domain-fresh"
    domain_execution_role_arn = null
    domain_service_role_arn   = null
  }

  # Role creation count should match the "created" output
  assert {
    condition     = (length(aws_iam_role.domain_execution) == 1) == output.domain_execution_role_created
    error_message = "Domain execution role creation count should be consistent with output flag"
  }

  assert {
    condition     = (length(aws_iam_role.domain_service) == 1) == output.domain_service_role_created
    error_message = "Domain service role creation count should be consistent with output flag"
  }

  # Policy attachment count should match role creation count
  assert {
    condition     = length(aws_iam_role_policy_attachment.domain_execution_policy) == length(aws_iam_role.domain_execution)
    error_message = "Domain execution policy attachment count should match role creation count"
  }

  assert {
    condition     = length(aws_iam_role_policy_attachment.domain_service_policy) == length(aws_iam_role.domain_service)
    error_message = "Domain service policy attachment count should match role creation count"
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
# Scenario 3: User provides only execution role
# Expected: Execution role skipped, service role depends on account state
#####################################################################################

run "domain_user_provides_only_execution_role" {
  command = plan
  module {
    source = "./"
  }

  variables {
    domain_name               = "test-domain-partial"
    domain_execution_role_arn = "arn:aws:iam::123456789012:role/MyCustomExecutionRole"
    domain_service_role_arn   = null
  }

  # Execution role should NOT be created (user provided it)
  assert {
    condition     = length(aws_iam_role.domain_execution) == 0
    error_message = "Domain execution role should NOT be created when user provides ARN"
  }

  assert {
    condition     = output.domain_execution_role_created == false
    error_message = "Output should indicate execution role was not created"
  }

  # Service role: creation depends on whether it exists in the account
  assert {
    condition     = (length(aws_iam_role.domain_service) == 1) == output.domain_service_role_created
    error_message = "Domain service role creation should be consistent with output flag"
  }

  # Domain should use the user-provided execution role
  assert {
    condition     = aws_datazone_domain.main.domain_execution_role == "arn:aws:iam::123456789012:role/MyCustomExecutionRole"
    error_message = "Domain should use user-provided execution role ARN"
  }
}

#####################################################################################
# Scenario 4: User provides only service role
# Expected: Service role skipped, execution role depends on account state
#####################################################################################

run "domain_user_provides_only_service_role" {
  command = plan
  module {
    source = "./"
  }

  variables {
    domain_name               = "test-domain-partial2"
    domain_execution_role_arn = null
    domain_service_role_arn   = "arn:aws:iam::123456789012:role/MyCustomServiceRole"
  }

  # Service role should NOT be created (user provided it)
  assert {
    condition     = length(aws_iam_role.domain_service) == 0
    error_message = "Domain service role should NOT be created when user provides ARN"
  }

  assert {
    condition     = output.domain_service_role_created == false
    error_message = "Output should indicate service role was not created"
  }

  # Execution role: creation depends on whether it exists in the account
  assert {
    condition     = (length(aws_iam_role.domain_execution) == 1) == output.domain_execution_role_created
    error_message = "Domain execution role creation should be consistent with output flag"
  }

  # Domain should use the user-provided service role
  assert {
    condition     = aws_datazone_domain.main.service_role == "arn:aws:iam::123456789012:role/MyCustomServiceRole"
    error_message = "Domain should use user-provided service role ARN"
  }
}

#####################################################################################
# Blueprint IAM role tests (Provisioning + ManageAccess)
# Uses real domain dzd-example123456 in us-east-2
# All tests use command = plan — nothing is created.
#####################################################################################

provider "aws" {
  alias  = "us_east_2"
  region = "us-east-2"
}

#####################################################################################
# Scenario 5: Blueprint - no roles provided
# Provisioning and ManageAccess creation depends on account state
#####################################################################################

run "blueprint_no_roles_provided_logic_consistent" {
  command = plan

  providers = {
    aws = aws.us_east_2
  }

  module {
    source = "./modules/blueprints"
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

  # Provisioning role: creation count should match output flag
  assert {
    condition     = (length(aws_iam_role.sagemaker_provisioning) == 1) == output.sagemaker_provisioning_role_created
    error_message = "Provisioning role creation count should be consistent with output flag"
  }

  # Manage access role: creation count should match output flag
  assert {
    condition     = (length(aws_iam_role.sagemaker_manage_access) == 1) == output.sagemaker_manage_access_role_created
    error_message = "Manage access role creation count should be consistent with output flag"
  }

  # Policy attachments should match role creation counts
  assert {
    condition     = length(aws_iam_role_policy_attachment.sagemaker_provisioning) == length(aws_iam_role.sagemaker_provisioning)
    error_message = "Provisioning policy attachment count should match role creation count"
  }

  assert {
    condition     = length(aws_iam_role_policy_attachment.sagemaker_manage_access) == length(aws_iam_role.sagemaker_manage_access)
    error_message = "SageMaker manage access policy attachment should match role creation count"
  }

  assert {
    condition     = length(aws_iam_role_policy_attachment.glue_manage_access) == length(aws_iam_role.sagemaker_manage_access)
    error_message = "Glue manage access policy attachment should match role creation count"
  }

  assert {
    condition     = length(aws_iam_role_policy_attachment.redshift_manage_access) == length(aws_iam_role.sagemaker_manage_access)
    error_message = "Redshift manage access policy attachment should match role creation count"
  }

  assert {
    condition     = length(aws_iam_policy.sagemaker_manage_access_redshift) == length(aws_iam_role.sagemaker_manage_access)
    error_message = "Customer managed policy creation should match role creation count"
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

#####################################################################################
# Scenario 7: Blueprint - user provides only manage access role
# Expected: Manage access skipped, provisioning depends on account state
#####################################################################################

run "blueprint_user_provides_only_manage_access" {
  command = plan

  providers = {
    aws = aws.us_east_2
  }

  module {
    source = "./modules/blueprints"
  }

  variables {
    domain_id                 = "dzd-example123456"
    domain_root_unit_id       = "dzd-example123456"
    manage_access_role_arn    = "arn:aws:iam::123456789012:role/MyCustomManageAccess"
    provisioning_role_arn     = null
    s3_bucket_name            = "test-bucket-789"
    vpc_id                    = "vpc-ghi789"
    subnet_ids                = ["subnet-ghi789"]
    domain_execution_role_arn = "arn:aws:iam::123456789012:role/service-role/AmazonSageMakerDomainExecution"
  }

  # Manage access: user provided, should NOT be created
  assert {
    condition     = length(aws_iam_role.sagemaker_manage_access) == 0
    error_message = "Manage access role should NOT be created when user provides ARN"
  }

  assert {
    condition     = output.sagemaker_manage_access_role_created == false
    error_message = "Output should indicate manage access role was not created"
  }

  # Provisioning: depends on account state
  assert {
    condition     = (length(aws_iam_role.sagemaker_provisioning) == 1) == output.sagemaker_provisioning_role_created
    error_message = "Provisioning role creation should be consistent with output flag"
  }
}

#####################################################################################
# Scenario 8: Blueprint - user provides only provisioning role
# Expected: Provisioning skipped, manage access depends on account state
#####################################################################################

run "blueprint_user_provides_only_provisioning" {
  command = plan

  providers = {
    aws = aws.us_east_2
  }

  module {
    source = "./modules/blueprints"
  }

  variables {
    domain_id                 = "dzd-example123456"
    domain_root_unit_id       = "dzd-example123456"
    manage_access_role_arn    = null
    provisioning_role_arn     = "arn:aws:iam::123456789012:role/MyCustomProvisioning"
    s3_bucket_name            = "test-bucket-abc"
    vpc_id                    = "vpc-jkl012"
    subnet_ids                = ["subnet-jkl012"]
    domain_execution_role_arn = "arn:aws:iam::123456789012:role/service-role/AmazonSageMakerDomainExecution"
  }

  # Provisioning: user provided, should NOT be created
  assert {
    condition     = length(aws_iam_role.sagemaker_provisioning) == 0
    error_message = "Provisioning role should NOT be created when user provides ARN"
  }

  assert {
    condition     = output.sagemaker_provisioning_role_created == false
    error_message = "Output should indicate provisioning role was not created"
  }

  # Manage access: depends on account state
  assert {
    condition     = (length(aws_iam_role.sagemaker_manage_access) == 1) == output.sagemaker_manage_access_role_created
    error_message = "Manage access role creation should be consistent with output flag"
  }
}
