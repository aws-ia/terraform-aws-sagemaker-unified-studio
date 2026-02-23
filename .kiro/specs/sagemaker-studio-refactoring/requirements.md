# Requirements Document

## Introduction

This document specifies the requirements for refactoring the SageMaker Unified Studio Terraform module project. The refactoring aims to improve modularity, enable better composition of blueprints and project profiles, ensure IAM role handling works in fresh AWS accounts, and achieve feature parity with the AWS console quick-setup experience.

**Tooling Requirement:** The implementation should utilize the Terraform MCP server (`hashicorp/terraform-mcp-server`) for looking up resource details during development. The Kiro instance should be configured with both the Terraform MCP server and the AWS Documentation MCP server. When editing Terraform resources, the model should look up resource names in the AWS docs and Terraform registry to validate correctness of resource types, attribute names, and argument values.

### Blueprints Problem Statement

The blueprints module currently configures multiple predefined blueprints simultaneously. As additional blueprint capabilities are added to SageMaker Unified Studio, the blueprint module will grow with repeated boilerplate resources created. Blueprints with special parameters are not properly documented and inputs are not properly validated to ensure correct creation. Moreover, blueprint configurations will grow depending on the regions where the blueprint is enabled, which is a feature that is not supported currently and would lead to significant repeated code to validate and configure each region. To simplify this deployment, we will modularize the blueprints module into a module that deploys a single blueprint at a time. The module will contain logic to validate inputs in detail for a single blueprint. This will help with the scalability and maintainability of the solution.

### Project Profiles Problem Statement

Similar to blueprints, the project profiles module creates profiles with multiple environment configurations in a monolithic fashion. Project profiles compose multiple blueprints into a single deployable capability. These profiles should be modular to support customers with varied use cases, allowing each profile to define which blueprints are included, what parameters are configurable, and which deployment modes are used.

## Glossary

- **Domain**: An AWS DataZone domain configured for SageMaker Unified Studio (V2)
- **Blueprint**: An environment blueprint that defines the infrastructure template for a specific type of environment (e.g., Tooling, LakehouseCatalog, MLExperiments). Configured via the `aws_datazone_environment_blueprint_configuration` Terraform resource.
- **Tooling_Blueprint**: A special required blueprint that provides shared infrastructure for project creation. It is always enabled when a domain is created to enable successful project creation even when no other blueprints are enabled to add additional capabilities.
- **Project_Profile**: A DataZone project profile that lists the environment configurations (blueprints) that will be deployed when a project is created using the project profile. It defines the configured and editable parameters for each blueprint as well as which regions and accounts the project is allowed to be created in. Configured via the `awscc_datazone_project_profile` Terraform resource.
- **Manage_Access_Role**: The `AmazonSageMakerManageAccess-<region>-<domainId>` role grants Amazon SageMaker Unified Studio permissions to publish, grant access, and revoke access to Amazon SageMaker Lakehouse, AWS Glue Data Catalog and Amazon Redshift data. It also grants Amazon SageMaker Unified Studio access to publish and manage subscriptions on Amazon SageMaker Catalog data and AI assets.
- **Provisioning_Role**: The `AmazonSageMakerProvisioning-<domainAccountId>` role is used by Amazon SageMaker Unified Studio to provision and manage resources defined in the selected blueprints in your account.
- **Domain_Execution_Role**: The `AmazonSageMakerDomainExecution` role has the AWS policy `SageMakerStudioDomainExecutionRolePolicy` attached. This is an IAM role that Amazon SageMaker Unified Studio requires to call APIs on behalf of authorized users, including those logged in to Amazon SageMaker Unified Studio.
- **Domain_Service_Role**: The `AmazonSageMakerDomainService` role has the AWS policy `SageMakerStudioDomainServiceRolePolicy` attached. This is a service role for domain level actions performed by Amazon SageMaker Unified Studio.
- **Model_Provisioning_Role**: Amazon SageMaker Unified Studio uses the `AmazonDataZoneBedrockModelManagementRole` to create an inference profile for an Amazon Bedrock model in a project. The inference profile is required for the project to interact with the model. You can either let Amazon SageMaker Unified Studio automatically create a unique provisioning role, or you can provide a custom provisioning role.
- **Model_Consumption_Role**: A consumption role (`AmazonDataZoneBedrockFMConsumptionRole`) is required for each Amazon Bedrock model that you want to enable in the playground for non-builders. Amazon SageMaker Unified Studio can create a consumption role per model by default or you have the option to configure a single existing consumption role for all models.
- **Blueprint_Specific_Roles**: Certain blueprints create their own IAM roles. For example: Bedrock Agent Execution role, Bedrock Agent Consumption role, Bedrock Flow Execution role, Bedrock Knowledge Base Execution role, and Lambda function execution role. These roles are created per-blueprint and are documented in the [supported blueprints list](https://docs.aws.amazon.com/sagemaker-unified-studio/latest/adminguide/supported-blueprints.html).
- **Regional_Parameters**: Configuration parameters specific to an AWS region (VPC, subnets, S3 location)
- **Console_Quick_Setup**: AWS console wizard for setting up SageMaker Unified Studio with guided configuration
- **AWS_Provider**: The primary Terraform provider (`aws`) used for most resources. This is the preferred provider for all resource creation.
- **AWSCC_Provider**: The AWS Cloud Control provider (`awscc`) used as a fallback when the `aws` provider lacks a required resource or attribute (e.g., the `global_parameters` attribute needed to enable specific blueprints is available in the `awscc` provider but not the `aws` provider).
- **Deployment_Mode**: A per-blueprint parameter in a project profile. `ON_CREATE` means the blueprint environment is created when the project is created. `ON_DEMAND` means the blueprint can be added to the project after creation (e.g., adding S3 Tables or EMR compute to an existing project).

## Requirements

### Requirement 1: Blueprint Module Singularization

**User Story:** As a Terraform user, I want to create a single blueprint configuration in a modular way, so that I can compose multiple blueprints independently and reuse the module for different blueprint types.

#### Acceptance Criteria

1. THE Blueprint_Module SHALL accept a `blueprint_name` as the primary input parameter (e.g., "LakeHouseDatabase", "EMRonEC2", "RedshiftServerless", "MLExperiments", etc.) and resolve the blueprint ID internally via a data lookup. Blueprint IDs are difficult-to-define strings that vary per region; users only know the plain text name from the [supported blueprints list](https://docs.aws.amazon.com/sagemaker-unified-studio/latest/adminguide/supported-blueprints.html).
2. WHEN the Blueprint_Module is invoked, THE Blueprint_Module SHALL create exactly one `aws_datazone_environment_blueprint_configuration` resource
3. THE Blueprint_Module SHALL accept all required configuration parameters including domain_id, manage_access_role_arn, provisioning_role_arn, vpc_id, subnet_ids, and s3_bucket_name
4. THE Blueprint_Module SHALL have a data source (`awscc_datazone_domain` or `data.aws_datazone_environment_blueprint`) for the domain_id specified, so it can look up additional details about the domain it is enabling the blueprint for
5. THE Blueprint_Module SHALL create an `awscc_datazone_policy_grant` resource for CREATE_ENVIRONMENT_FROM_BLUEPRINT permission to the root domain unit of the domain, including child domain units by default
6. THE Blueprint_Module SHALL accept a `create_roles` toggle parameter. IF `create_roles` is true, THE Blueprint_Module SHALL auto-create all required roles when the corresponding role ARN argument is empty. IF `create_roles` is false and a required role ARN is not provided, THEN THE Blueprint_Module SHALL fail validation. THE Blueprint_Module SHALL NOT auto-create roles when `create_roles` is false.
7. THE Blueprint_Module SHALL be reusable such that it can be invoked multiple times with different blueprint_name values
8. THE Blueprint_Module SHALL fail if the blueprint is already configured in the same account for the given domain unless an override flag (`allow_replace_existing`) is set to true. Blueprint configurations are an account-wide setting (like data catalog encryption or turning on Lake Formation); creating a new configuration for a blueprint ID for an existing account and domain replaces the existing configuration.
9. THE Blueprint_Module SHALL perform validation on the format of the vpc_id input to match the pattern `vpc-xxx`
10. THE Blueprint_Module SHALL perform validation on the format of the subnet_ids input to match the pattern `subnet-xxx`
11. THE Blueprint_Module SHALL perform a data lookup on the subnet IDs to ensure each subnet is within the configured vpc_id

### Requirement 2: Project Profile Module Singularization

**User Story:** As a Terraform user, I want to create a single project profile that accepts a dictionary of blueprints and their parameters, so that I can easily compose project profiles with different environment combinations, default values, and editable parameters.

#### Acceptance Criteria

1. THE Project_Profile_Module SHALL accept a dictionary of blueprints as input, where each entry specifies the blueprint name, its default parameter values, which parameters are editable by a created project, and a `deployment_mode` (`ON_CREATE` or `ON_DEMAND`)
2. THE Project_Profile_Module SHALL create exactly one `awscc_datazone_project_profile` resource
3. THE Project_Profile_Module SHALL accept a custom profile name as an input parameter
4. THE Project_Profile_Module SHALL create a Terraform data resource to look up the Tooling_Blueprint for the account and region where the project profile is being enabled and apply it as the first resource in environment_configurations
5. IF the data resource indicates the Tooling_Blueprint is not configured for the account and region, THEN THE Project_Profile_Module SHALL fail creation
6. IF the Tooling_Blueprint is passed as a parameter in the blueprint dictionary, THEN THE Project_Profile_Module SHALL ignore the user-specified Tooling configuration and use the looked-up configuration instead

### Requirement 3: Tooling Blueprint Integration

**User Story:** As a Terraform user, I want the Tooling blueprint to be automatically created as part of the domain, since it is a required blueprint that must always exist for SageMaker Unified Studio to function.

The Tooling blueprint is a special blueprint that is required to deploy the basic project resources. It will always be enabled when a domain is created to enable successful project creation even when no other blueprints are enabled to add additional capabilities. Instead of being deployed in the Blueprint_Module, the Tooling blueprint will be deployed within the Domain_Module alongside the domain.

#### Acceptance Criteria

1. THE Domain_Module SHALL create the Tooling_Blueprint configuration automatically during domain creation
2. WHEN creating the Tooling_Blueprint, THE Domain_Module SHALL use the awscc provider
3. THE Domain_Module SHALL create the Tooling_Blueprint after the domain resource but before any other blueprints
4. THE Domain_Module SHALL output the tooling_blueprint_id for use by other modules
5. THE Domain_Module SHALL accept VPC, subnet, and S3 bucket parameters for Tooling_Blueprint configuration
6. THE Domain_Module SHALL configure the Tooling_Blueprint with the Query Execution role global parameters using the awscc provider
7. THE Domain_Module SHALL create a dedicated S3 bucket for the domain if a customer S3 bucket ARN/name is not supplied, and attach it to the Tooling_Blueprint configuration

### Requirement 4: IAM Role Existence Validation and Creation

**User Story:** As a Terraform user, I want the module to support both automatic IAM role creation and externally-managed roles, so that I can deploy to fresh AWS accounts while also supporting regulated industries (e.g., HCLS) that require review and approval for IAM roles with specific naming policies.

#### Acceptance Criteria

1. THE Domain_Module SHALL accept a `create_roles` toggle parameter (default: true)
2. WHEN `create_roles` is true and the AmazonSageMakerDomainExecution role does not exist, THE Domain_Module SHALL create it with the appropriate trust policy and attach the `SageMakerStudioDomainExecutionRolePolicy` managed policy
3. WHEN `create_roles` is true and the AmazonSageMakerDomainService role does not exist, THE Domain_Module SHALL create it with the appropriate trust policy and attach the `SageMakerStudioDomainServiceRolePolicy` managed policy
4. IF `create_roles` is false and required role ARNs are not provided, THEN THE Domain_Module SHALL fail validation
5. THE Domain_Module SHALL create IAM roles before creating the domain resource
6. THE Domain_Module SHALL output the domain_execution_role_arn and domain_service_role_arn for use by other modules
7. WHEN `create_roles` is true and only one of the two default roles exists, THE Domain_Module SHALL create only the missing role

### Requirement 5: VPC Configuration Parameters

**User Story:** As a Terraform user, I want to configure VPC and subnet parameters for blueprints, so that I have the same configuration options available in the AWS console quick-setup.

#### Acceptance Criteria

1. THE Blueprint_Module SHALL accept a vpc_id parameter as required input
2. THE Blueprint_Module SHALL accept a subnet_ids parameter as a list of strings as required input
3. WHEN configuring regional_parameters, THE Blueprint_Module SHALL include the vpc_id in the VpcId parameter
4. WHEN configuring regional_parameters, THE Blueprint_Module SHALL include the subnet_ids in the Subnets parameter
5. THE Blueprint_Module SHALL validate that the vpc_id and subnet_ids are in the same AWS region as the blueprint configuration
6. THE Blueprint_Module SHALL perform validation on the format of the vpc_id input to match the pattern `vpc-xxx`
7. THE Blueprint_Module SHALL perform validation on the format of the subnet_ids input to match the pattern `subnet-xxx`
8. THE Blueprint_Module SHALL perform a data lookup on the subnet IDs to ensure each subnet is within the configured vpc_id

### Requirement 6: Model Provisioning Role Configuration

**User Story:** As a Terraform user, I want to configure the `AmazonDataZoneBedrockModelManagementRole` for creating inference profiles with Amazon Bedrock model access, so that I have the same model configuration options available in the AWS console quick-setup.

#### Acceptance Criteria

1. THE Domain_Module SHALL accept a `model_management_role_arn` parameter as optional input (corresponding to the `AmazonDataZoneBedrockModelManagementRole`)
2. WHERE the `model_management_role_arn` is not provided and `create_roles` is true, THE Domain_Module SHALL create a default `AmazonDataZoneBedrockModelManagementRole` with permissions to create inference profiles with Amazon Bedrock
3. IF `model_management_role_arn` is not provided and `create_roles` is false, THEN THE Domain_Module SHALL fail validation
4. THE Domain_Module SHALL use the `model_management_role_arn` when configuring the hidden model governance project. The hidden model governance project is an empty project with no environment configurations (not even Tooling); it is simply a logical container of users that are allowed to edit which models are allowed for the domain.
5. THE Domain_Module SHALL output the model_management_role_arn for reference

### Requirement 7: Model Consumption Role Configuration

**User Story:** As a Terraform user, I want to optionally configure a model consumption role, so that I have the same model consumption configuration options available in the AWS console quick-setup.

#### Acceptance Criteria

1. THE Domain_Module SHALL accept a `model_consumption_role_arn` parameter as optional input (corresponding to the `AmazonDataZoneBedrockFMConsumptionRole`)
2. IF `model_consumption_role_arn` is not provided and `create_roles` is true, THEN THE Domain_Module SHALL auto-create the `AmazonDataZoneBedrockFMConsumptionRole`
3. IF `model_consumption_role_arn` is not provided and `create_roles` is false, THEN THE Domain_Module SHALL fail validation
4. WHEN `model_consumption_role_arn` is provided, THE Domain_Module SHALL use the provided role ARN for model consumption configuration

### Requirement 8: User Role Policy Configuration

**User Story:** As a Terraform user, I want to configure a user role policy for domain users, so that I can control user permissions in the same way as the AWS console quick-setup.

#### Acceptance Criteria

1. THE Domain_Module SHALL accept a user_role_policy_arn parameter as optional input
2. WHEN user_role_policy_arn is provided, THE Domain_Module SHALL apply the user_role_policy_arn to the Tooling_Blueprint configuration (not the domain configuration), since the user role policy is attached to the Tooling blueprint within the Domain_Module
3. IF the AWS provider does not support user role policy configuration on the Tooling_Blueprint, THEN THE Domain_Module SHALL use the awscc provider to apply the user_role_policy_arn
4. THE Domain_Module SHALL validate that the user_role_policy_arn is a valid IAM policy ARN format

### Requirement 9: Quick-Setup Example Modernization

**User Story:** As a Terraform user learning this module, I want the quick-setup example to demonstrate the new modular approach and match AWS console quick-setup functionality, so that I can understand best practices for using the refactored modules.

#### Acceptance Criteria

1. THE Quick_Setup_Example SHALL use the singular Blueprint_Module multiple times for different blueprint types
2. THE Quick_Setup_Example SHALL use the singular Project_Profile_Module with a dictionary of blueprints
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
