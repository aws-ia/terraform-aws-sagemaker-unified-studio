#####################################################################################
# Singular Project Profile Module Tests
# All tests use command = plan — nothing is created in your AWS account.
#####################################################################################

#####################################################################################
# Scenario 1: Basic profile with Tooling only
#####################################################################################

run "profile_tooling_only" {
  command = plan

  module {
    source = "./modules/project-profile"
  }

  override_data {
    target = data.aws_datazone_environment_blueprint.this["Tooling"]
    values = { id = "mock-tooling-id" }
  }

  variables {
    domain_id = "dzd-test123456"
    name      = "Basic Profile"
    blueprints = {
      Tooling = {}
    }
  }

  assert {
    condition     = awscc_datazone_project_profile.this.name == "Basic Profile"
    error_message = "Profile name should match input"
  }

  assert {
    condition     = awscc_datazone_project_profile.this.domain_identifier == "dzd-test123456"
    error_message = "Domain ID should match input"
  }

  assert {
    condition     = awscc_datazone_project_profile.this.status == "ENABLED"
    error_message = "Default status should be ENABLED"
  }

  assert {
    condition     = length(awscc_datazone_project_profile.this.environment_configurations) == 1
    error_message = "Should have exactly 1 environment configuration"
  }

  assert {
    condition     = output.blueprint_count == 1
    error_message = "Blueprint count should be 1"
  }
}

#####################################################################################
# Scenario 2: Multi-blueprint profile — Tooling always first
#####################################################################################

run "profile_multi_blueprint_ordering" {
  command = plan

  module {
    source = "./modules/project-profile"
  }

  override_data {
    target = data.aws_datazone_environment_blueprint.this["Tooling"]
    values = { id = "mock-tooling-id" }
  }

  override_data {
    target = data.aws_datazone_environment_blueprint.this["RedshiftServerless"]
    values = { id = "mock-redshift-id" }
  }

  override_data {
    target = data.aws_datazone_environment_blueprint.this["DataLake"]
    values = { id = "mock-datalake-id" }
  }

  variables {
    domain_id = "dzd-test123456"
    name      = "Data Engineering"
    blueprints = {
      Tooling            = {}
      RedshiftServerless = {}
      DataLake           = {}
    }
  }

  assert {
    condition     = length(awscc_datazone_project_profile.this.environment_configurations) == 3
    error_message = "Should have 3 environment configurations"
  }

  # Tooling must be first (deployment_order = 1)
  assert {
    condition     = awscc_datazone_project_profile.this.environment_configurations[0].name == "Tooling"
    error_message = "Tooling should be first environment configuration"
  }

  assert {
    condition     = awscc_datazone_project_profile.this.environment_configurations[0].deployment_order == 1
    error_message = "Tooling should have deployment_order = 1"
  }

  # Others alphabetical: DataLake (2), RedshiftServerless (3)
  assert {
    condition     = awscc_datazone_project_profile.this.environment_configurations[1].name == "DataLake"
    error_message = "DataLake should be second (alphabetical)"
  }

  assert {
    condition     = awscc_datazone_project_profile.this.environment_configurations[1].deployment_order == 2
    error_message = "DataLake should have deployment_order = 2"
  }

  assert {
    condition     = awscc_datazone_project_profile.this.environment_configurations[2].name == "RedshiftServerless"
    error_message = "RedshiftServerless should be third (alphabetical)"
  }

  assert {
    condition     = awscc_datazone_project_profile.this.environment_configurations[2].deployment_order == 3
    error_message = "RedshiftServerless should have deployment_order = 3"
  }

  assert {
    condition     = output.blueprint_count == 3
    error_message = "Blueprint count should be 3"
  }
}

#####################################################################################
# Scenario 3: Parameter overrides are passed correctly
#####################################################################################

run "profile_parameter_overrides" {
  command = plan

  module {
    source = "./modules/project-profile"
  }

  override_data {
    target = data.aws_datazone_environment_blueprint.this["Tooling"]
    values = { id = "mock-tooling-id" }
  }

  override_data {
    target = data.aws_datazone_environment_blueprint.this["DataLake"]
    values = { id = "mock-datalake-id" }
  }

  variables {
    domain_id = "dzd-test123456"
    name      = "Custom Params Profile"
    blueprints = {
      Tooling = {
        parameter_overrides = { idleTimeoutInMinutes = "120", maxEbsVolumeSize = "200" }
      }
      DataLake = {
        parameter_overrides = { glueDbName = "analytics_db" }
      }
    }
  }

  assert {
    condition     = awscc_datazone_project_profile.this.environment_configurations[0].configuration_parameters != null
    error_message = "Tooling should have configuration_parameters set"
  }

  assert {
    condition     = awscc_datazone_project_profile.this.environment_configurations[1].configuration_parameters != null
    error_message = "DataLake should have configuration_parameters set"
  }

  assert {
    condition     = length(awscc_datazone_project_profile.this.environment_configurations) == 2
    error_message = "Should have 2 environment configurations"
  }
}

#####################################################################################
# Scenario 4: No parameter overrides
#####################################################################################

run "profile_no_overrides" {
  command = plan

  module {
    source = "./modules/project-profile"
  }

  override_data {
    target = data.aws_datazone_environment_blueprint.this["Tooling"]
    values = { id = "mock-tooling-id" }
  }

  override_data {
    target = data.aws_datazone_environment_blueprint.this["DataLake"]
    values = { id = "mock-datalake-id" }
  }

  variables {
    domain_id = "dzd-test123456"
    name      = "Defaults Profile"
    blueprints = {
      Tooling  = {}
      DataLake = {}
    }
  }

  assert {
    condition     = length(awscc_datazone_project_profile.this.environment_configurations) == 2
    error_message = "Should have 2 environment configurations"
  }

  assert {
    condition     = awscc_datazone_project_profile.this.environment_configurations[0].name == "Tooling"
    error_message = "First config should be Tooling"
  }

  assert {
    condition     = awscc_datazone_project_profile.this.environment_configurations[1].name == "DataLake"
    error_message = "Second config should be DataLake"
  }
}

#####################################################################################
# Scenario 5: ON_DEMAND deployment mode
#####################################################################################

run "profile_on_demand_deployment" {
  command = plan

  module {
    source = "./modules/project-profile"
  }

  override_data {
    target = data.aws_datazone_environment_blueprint.this["Tooling"]
    values = { id = "mock-tooling-id" }
  }

  override_data {
    target = data.aws_datazone_environment_blueprint.this["RedshiftServerless"]
    values = { id = "mock-redshift-id" }
  }

  variables {
    domain_id = "dzd-test123456"
    name      = "On Demand Profile"
    blueprints = {
      Tooling = {}
      RedshiftServerless = {
        deployment_mode = "ON_DEMAND"
      }
    }
  }

  assert {
    condition     = awscc_datazone_project_profile.this.environment_configurations[0].deployment_mode == "ON_CREATE"
    error_message = "Tooling should default to ON_CREATE"
  }

  assert {
    condition     = awscc_datazone_project_profile.this.environment_configurations[1].deployment_mode == "ON_DEMAND"
    error_message = "RedshiftServerless should be ON_DEMAND"
  }
}

#####################################################################################
# Scenario 6: Disabled profile
#####################################################################################

run "profile_disabled_status" {
  command = plan

  module {
    source = "./modules/project-profile"
  }

  override_data {
    target = data.aws_datazone_environment_blueprint.this["Tooling"]
    values = { id = "mock-tooling-id" }
  }

  variables {
    domain_id = "dzd-test123456"
    name      = "Disabled Profile"
    status    = "DISABLED"
    blueprints = {
      Tooling = {}
    }
  }

  assert {
    condition     = awscc_datazone_project_profile.this.status == "DISABLED"
    error_message = "Profile status should be DISABLED"
  }
}
