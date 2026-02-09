# Requirements Document

## Introduction

This document specifies the requirements for refactoring the SageMaker Unified Studio Terraform module project. The refactoring aims to improve modularity, enable better composition of blueprints and project profiles, ensure IAM role handling works in fresh AWS accounts, and achieve feature parity with the AWS console quick-setup experience.

The current implementation uses a monolithic approach where the blueprints module configures multiple blueprints simultaneously, and the project-profiles module creates profiles with multiple environment configurations. This refactoring will decompose these into singular, reusable modules that can be composed together, while integrating the required Tooling blueprint into the root domain module.

## Glossary

- **Domain**: An AWS DataZone domain configured for SageMaker Unified Studio (V2)
- **Blueprint**: An environment blueprint that defines the infrastructure template for a specific type of environment (e.g., Tooling, LakehouseCatalog, MLExperiments)
- **Tooling_Blueprint**: A special required blueprint that provides shared infrastructure and must always be created first
- **Project_Profile**: A DataZone project profile that combines multiple environment configurations with deployment ordering
- **Manage_Access_Role**: IAM role used by SageMaker to manage access to AWS resources
- **Provisioning_Role**: IAM role used to provision blueprint resources
- **Domain_Execution_Role**: IAM role that executes domain-level operations (default: AmazonSageMakerDomainExecution)
- **Domain_Service_Role**: IAM role for domain service operations (default: AmazonSageMakerDomainService)
- **Model_Provisioning_Role**: IAM role used to create inference profiles with Amazon Bedrock model access
- **Model_Consumption_Role**: IAM role used to consume models (can be managed or existing)
- **Regional_Parameters**: Configuration parameters specific to an AWS region (VPC, subnets, S3 location)
- **Console_Quick_Setup**: AWS console wizard for setting up SageMaker Unified Studio with guided configuration
- **AWSCC_Provider**: AWS Cloud Control provider required for certain DataZone resources with global parameters

## Requirements

### Requirement 1: Blueprint Module Singularization

**User Story:** As a Terraform user, I want to create a single blueprint configuration in a modular way, so that I can compose multiple blueprints independently and reuse the module for different blueprint types.

#### Acceptance Criteria

1. THE Blueprint_Module SHALL accept a single blueprint_id as the primary input parameter
2. WHEN the Blueprint_Module is invoked, THE Blueprint_Module SHALL create exactly one aws_datazone_environment_blueprint_configuration resource
3. THE Blueprint_Module SHALL accept all required configuration parameters including domain_id, manage_access_role_arn, provisioning_role_arn, vpc_id, subnet_ids, and s3_bucket_name
4. THE Blueprint_Module SHALL create a policy grant for CREATE_ENVIRONMENT_FROM_BLUEPRINT permission
5. WHERE the manage_access_role_arn is not provided, THE Blueprint_Module SHALL create an IAM role with AmazonSageMakerManageAccess permissions
6. THE Blueprint_Module SHALL be reusable such that it can be invoked multiple times with different blueprint_id values

### Requirement 2: Project Profile Module Singularization

**User Story:** As a Terraform user, I want to create a single project profile that accepts a list of blueprint IDs, so that I can easily compose project profiles with different environment combinations without managing complex configuration arrays.

#### Acceptance Criteria

1. THE Project_Profile_Module SHALL accept a list of blueprint_ids as input
2. WHEN building environment_configurations, THE Project_Profile_Module SHALL ensure the Tooling_Blueprint has deployment_order equal to 1
3. THE Project_Profile_Module SHALL automatically assign deployment_order values to non-Tooling blueprints in sequential order
4. THE Project_Profile_Module SHALL create exactly one awscc_datazone_project_profile resource
5. THE Project_Profile_Module SHALL accept custom profile name as an input parameter
6. WHEN a blueprint_id in the list corresponds to the Tooling_Blueprint, THE Project_Profile_Module SHALL place it first in the environment_configurations array *_*
7. THE Project_Profile_Module SHALL validate that all blueprint_ids in the input list are valid blueprint identifiers

### Requirement 3: Tooling Blueprint Integration

**User Story:** As a Terraform user, I want the Tooling blueprint to be automatically created as part of the domain, since it is a required blueprint that must always exist for SageMaker Unified Studio to function.

#### Acceptance Criteria

1. THE Domain_Module SHALL create the Tooling_Blueprint configuration automatically during domain creation
2. WHEN creating the Tooling_Blueprint, THE Domain_Module SHALL use the awscc provider
3. THE Domain_Module SHALL create the Tooling_Blueprint after the domain resource but before any other blueprints
4. THE Domain_Module SHALL output the tooling_blueprint_id for use by other modules
5. THE Domain_Module SHALL accept VPC, subnet, and S3 bucket parameters for Tooling_Blueprint configuration
6. THE Domain_Module SHALL configure the Tooling_Blueprint with the Query Execution role global parameters using the awscc provider

### Requirement 4: IAM Role Existence Validation and Creation

**User Story:** As a Terraform user, I want the module to automatically create default IAM roles if they don't exist, so that I don't encounter errors when deploying to a fresh AWS account that has never had a SageMaker domain created via the console.

#### Acceptance Criteria

1. WHEN the Domain_Module is invoked, THE Domain_Module SHALL check if the AmazonSageMakerDomainExecution role exists
2. IF the AmazonSageMakerDomainExecution role does not exist, THEN THE Domain_Module SHALL create it with the appropriate trust policy and attach the SageMakerStudioDomainExecutionRolePolicy managed policy
3. WHEN the Domain_Module is invoked, THE Domain_Module SHALL check if the AmazonSageMakerDomainService role exists
4. IF the AmazonSageMakerDomainService role does not exist, THEN THE Domain_Module SHALL create it with the appropriate trust policy and attach the SageMakerStudioDomainServiceRolePolicy managed policy
5. THE Domain_Module SHALL create IAM roles before creating the domain resource
6. THE Domain_Module SHALL output the domain_execution_role_arn and domain_service_role_arn for use by other modules
7. WHEN only one of the two default roles exists, THE Domain_Module SHALL create only the missing role

### Requirement 5: VPC Configuration Parameters

**User Story:** As a Terraform user, I want to configure VPC and subnet parameters for blueprints, so that I have the same configuration options available in the AWS console quick-setup.

#### Acceptance Criteria

1. THE Blueprint_Module SHALL accept a vpc_id parameter as required input
2. THE Blueprint_Module SHALL accept a subnet_ids parameter as a list of strings as required input
3. WHEN configuring regional_parameters, THE Blueprint_Module SHALL include the vpc_id in the VpcId parameter
4. WHEN configuring regional_parameters, THE Blueprint_Module SHALL include the subnet_ids in the Subnets parameter
5. THE Blueprint_Module SHALL validate that the vpc_id and subnet_ids are in the same AWS region as the blueprint configuration

### Requirement 6: Model Provisioning Role Configuration

**User Story:** As a Terraform user, I want to configure a model provisioning role for creating inference profiles with Amazon Bedrock model access, so that I have the same model configuration options available in the AWS console quick-setup.

#### Acceptance Criteria

1. THE Domain_Module SHALL accept a model_provisioning_role_arn parameter as optional input
2. WHERE the model_provisioning_role_arn is not provided, THE Domain_Module SHALL create a default role with permissions to create inference profiles with Amazon Bedrock
3. THE Domain_Module SHALL use the model_provisioning_role_arn when configuring the hidden model governance project
4. THE Domain_Module SHALL output the model_provisioning_role_arn for reference

### Requirement 7: Model Consumption Role Configuration

**User Story:** As a Terraform user, I want to choose between managed and existing model consumption roles, so that I have the same model consumption configuration options available in the AWS console quick-setup.

#### Acceptance Criteria

1. THE Domain_Module SHALL accept a model_consumption_role_type parameter with allowed values "managed" or "existing"
2. WHEN model_consumption_role_type is "managed", THE Domain_Module SHALL configure SageMaker Unified Studio to use managed roles for each model
3. WHEN model_consumption_role_type is "existing", THE Domain_Module SHALL require a model_consumption_role_arn parameter
4. WHEN model_consumption_role_type is "existing", THE Domain_Module SHALL use the provided model_consumption_role_arn for model consumption
5. THE Domain_Module SHALL validate that model_consumption_role_arn is provided when model_consumption_role_type is "existing"

### Requirement 8: User Role Policy Configuration

**User Story:** As a Terraform user, I want to configure a user role policy for domain users, so that I can control user permissions in the same way as the AWS console quick-setup.

#### Acceptance Criteria

1. THE Domain_Module SHALL accept a user_role_policy_arn parameter as optional input
2. IF the AWS provider supports user role policy configuration for DataZone domains, THEN THE Domain_Module SHALL apply the user_role_policy_arn to the domain configuration
3. IF the AWS provider does not support user role policy configuration, THEN THE Domain_Module SHALL document this limitation and provide a workaround in the module documentation
4. THE Domain_Module SHALL validate that the user_role_policy_arn is a valid IAM policy ARN format

### Requirement 9: Quick-Setup Example Modernization

**User Story:** As a Terraform user learning this module, I want the quick-setup example to demonstrate the new modular approach and match AWS console quick-setup functionality, so that I can understand best practices for using the refactored modules.

#### Acceptance Criteria

1. THE Quick_Setup_Example SHALL use the singular Blueprint_Module multiple times for different blueprint types
2. THE Quick_Setup_Example SHALL use the singular Project_Profile_Module with a list of blueprint_ids
3. THE Quick_Setup_Example SHALL demonstrate Tooling_Blueprint integration from the Domain_Module
4. THE Quick_Setup_Example SHALL demonstrate VPC configuration parameters
5. THE Quick_Setup_Example SHALL demonstrate model provisioning and consumption role configuration
6. THE Quick_Setup_Example SHALL demonstrate user role policy configuration
7. THE Quick_Setup_Example SHALL maintain S3 cleanup functionality on destroy
8. THE Quick_Setup_Example SHALL maintain SSO user and project membership functionality

### Requirement 10: Module Testing

**User Story:** As a module maintainer, I want comprehensive tests for the refactored modules, so that I can ensure the modules work correctly and catch regressions.

#### Acceptance Criteria

1. THE Module_Tests SHALL include a Terraform plan test for each module
2. THE Module_Tests SHALL include a Terraform apply test for each module