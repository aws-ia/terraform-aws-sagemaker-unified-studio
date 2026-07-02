#####################################################################################
# SageMaker Unified Studio Quick-Setup Example
#
# Demonstrates the modular architecture:
#   1. Root domain module — creates domain, Tooling blueprint, IAM roles, S3 bucket,
#      model governance resources
#   2. Blueprint module (singular) — invoked per blueprint (LakehouseCatalog,
#      MLExperiments, RedshiftServerless)
#   3. Project profile module (singular) — composes blueprints into a deployable profile
#   4. Project module — creates a project from the profile
#
# Equivalent to the AWS console quick-setup experience.
#####################################################################################

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "SageMaker-Unified-Studio"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Example     = "quick-setup"
    }
  }
}

# Configure the AWS Cloud Control Provider (awscc) to use the same region
provider "awscc" {
  region = var.aws_region
}

#####################################################################################
# Data Sources
#####################################################################################

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Use default VPC/subnets when not explicitly provided
data "aws_vpc" "default" {
  count   = var.vpc_id == null ? 1 : 0
  default = true
}

data "aws_subnets" "default" {
  count = var.subnet_ids == null ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default[0].id]
  }
}

#####################################################################################
# Locals
#####################################################################################

locals {
  vpc_id     = var.vpc_id != null ? var.vpc_id : data.aws_vpc.default[0].id
  subnet_ids = var.subnet_ids != null ? var.subnet_ids : data.aws_subnets.default[0].ids
  region     = data.aws_region.current.id

  # Dynamic project name with random suffix for uniqueness
  project_name = "${var.project_name}-${random_id.project_suffix.hex}"

  common_tags = {
    DomainName  = var.domain_name
    Environment = var.environment
    Owner       = var.owner
    CreatedBy   = "terraform-quick-setup-example"
  }

  # Build the map of blueprints to enable based on toggle variables
  blueprint_configs = merge(
    # Bedrock and QuickSight blueprints do not take VPC/subnet regional parameters.
    (var.enable_generative_ai || var.enable_all_capabilities) ? {
      amazon_bedrock_chat_agent = {
        blueprint_name            = "AmazonBedrockChatAgent"
        needs_regional_parameters = false
      }
      amazon_bedrock_evaluation = {
        blueprint_name            = "AmazonBedrockEvaluation"
        needs_regional_parameters = false
      }
      amazon_bedrock_flow = {
        blueprint_name            = "AmazonBedrockFlow"
        needs_regional_parameters = false
      }
      amazon_bedrock_function = {
        blueprint_name            = "AmazonBedrockFunction"
        needs_regional_parameters = false
      }
      amazon_bedrock_guardrail = {
        blueprint_name            = "AmazonBedrockGuardrail"
        needs_regional_parameters = false
      }
      amazon_bedrock_knowledge_base = {
        blueprint_name            = "AmazonBedrockKnowledgeBase"
        needs_regional_parameters = false
      }
      amazon_bedrock_prompt = {
        blueprint_name            = "AmazonBedrockPrompt"
        needs_regional_parameters = false
      }
    } : {},
    (var.enable_sql_analytics || var.enable_all_capabilities) ? {
      lakehouse_database = {
        blueprint_name            = "DataLake"
        needs_regional_parameters = true
      }
      lakehouse_catalog = {
        blueprint_name            = "LakehouseCatalog"
        needs_regional_parameters = true
      }
      redshift_serverless = {
        blueprint_name            = "RedshiftServerless"
        needs_regional_parameters = true
      }
      quicksight = {
        blueprint_name            = "QuickSight"
        needs_regional_parameters = false
      }
    } : {},
    (var.enable_all_capabilities) ? {
      emr_serverless = {
        blueprint_name            = "EmrServerless"
        needs_regional_parameters = true
      }
      emr_on_ec2 = {
        blueprint_name            = "EmrOnEc2"
        needs_regional_parameters = true
      }
      ml_experiments = {
        blueprint_name            = "MLExperiments"
        needs_regional_parameters = true
      }
      workflows = {
        blueprint_name            = "Workflows"
        needs_regional_parameters = true
      }
    } : {},
  )

  # SQL analytics profile
  sql_analytics_blueprint_config = {
    "Lakehouse Database" = {
      blueprint       = "DataLake"
      description     = "Creates databases in SageMaker Lakehouse for S3 tables and Athena"
      deployment_mode = "ON_CREATE"
      parameter_overrides = {
        "glueDbName" = { value = "glue_db", is_editable = true }
      }
    }
    "Redshift Serverless" = {
      blueprint       = "RedshiftServerless"
      description     = "Creates an Amazon Redshift Serverless workgroup"
      deployment_mode = "ON_CREATE"
      parameter_overrides = {
        "redshiftDbName"      = { value = "dev", is_editable = true }
        "connectToRMSCatalog" = { value = "true", is_editable = false }
        "redshiftMaxCapacity" = { value = "512", is_editable = false }
      }
    }
    "OnDemand Redshift Serverless" = {
      blueprint       = "RedshiftServerless"
      description     = "Additional Redshift Serverless workgroup"
      deployment_mode = "ON_DEMAND"
      parameter_overrides = {
        "redshiftDbName"        = { value = "dev", is_editable = true }
        "redshiftMaxCapacity"   = { value = "512", is_editable = true }
        "redshiftWorkgroupName" = { value = "redshift-serverless-workgroup", is_editable = true }
        "redshiftBaseCapacity"  = { value = "128", is_editable = true }
        "connectionName"        = { value = "redshift.serverless", is_editable = true }
        "connectToRMSCatalog"   = { value = "false", is_editable = false }
      }
    }
    "OnDemand Catalog for RMS" = {
      blueprint       = "LakehouseCatalog"
      description     = "Catalog for Redshift Managed Storage"
      deployment_mode = "ON_DEMAND"
      parameter_overrides = {
        "catalogName"        = { value = "", is_editable = true }
        "catalogDescription" = { value = "RMS catalog", is_editable = true }
      }
    }
    "OnDemand QuickSight" = {
      blueprint       = "QuickSight"
      description     = "Amazon QuickSight for data visualization"
      deployment_mode = "ON_DEMAND"
    }
  }

  # Generative AI profile
  generative_ai_blueprint_config = {
    "Amazon Bedrock Chat Agent" = {
      blueprint       = "AmazonBedrockChatAgent"
      description     = "A configurable generative AI app with a conversational interface"
      deployment_mode = "ON_DEMAND"
    }
    "Amazon Bedrock Knowledge Base" = {
      blueprint       = "AmazonBedrockKnowledgeBase"
      description     = "A reusable component for providing your own data to apps"
      deployment_mode = "ON_DEMAND"
    }
    "Amazon Bedrock Guardrail" = {
      blueprint       = "AmazonBedrockGuardrail"
      description     = "A reusable component for implementing safeguards on model outputs"
      deployment_mode = "ON_DEMAND"
    }
    "Amazon Bedrock Function" = {
      blueprint       = "AmazonBedrockFunction"
      description     = "A reusable component for including dynamic information in model outputs"
      deployment_mode = "ON_DEMAND"
    }
    "Amazon Bedrock Flow" = {
      blueprint       = "AmazonBedrockFlow"
      description     = "A configurable generative AI workflow"
      deployment_mode = "ON_DEMAND"
    }
    "Amazon Bedrock Prompt" = {
      blueprint       = "AmazonBedrockPrompt"
      description     = "A reusable set of inputs that guide model outputs"
      deployment_mode = "ON_DEMAND"
    }
    "Amazon Bedrock Evaluation" = {
      blueprint       = "AmazonBedrockEvaluation"
      description     = "Enables evaluation features to compare Bedrock models"
      deployment_mode = "ON_DEMAND"
    }
  }

  # All capabilities profile
  all_capabilities_blueprint_config = {
    "Lakehouse Database" = {
      blueprint       = "DataLake"
      description     = "Creates databases in Amazon SageMaker Lakehouse for storing tables in S3 and Amazon Athena resources for your SQL workloads"
      deployment_mode = "ON_CREATE"
      parameter_overrides = {
        "glueDbName" = { value = "glue_db", is_editable = true }
      }
    }
    "RedshiftServerless" = {
      blueprint       = "RedshiftServerless"
      description     = "Creates an Amazon Redshift Serverless workgroup for your SQL workloads"
      deployment_mode = "ON_CREATE"
      parameter_overrides = {
        "redshiftDbName"      = { value = "dev", is_editable = true }
        "connectToRMSCatalog" = { value = "true", is_editable = false }
        "redshiftMaxCapacity" = { value = "512", is_editable = false }
      }
    }
    "OnDemand Workflows" = {
      blueprint       = "Workflows"
      description     = "Enables you to create Airflow workflows to be executed on MWAA environments"
      deployment_mode = "ON_DEMAND"
      parameter_overrides = {
        "environmentClass" = { value = "mw1.micro", is_editable = false }
      }
    }
    "OnDemand MLExperiments" = {
      blueprint       = "MLExperiments"
      description     = "Enables you to create Amazon Sagemaker mlflow in the project"
      deployment_mode = "ON_DEMAND"
      parameter_overrides = {
        "mlflowTrackingServerSize" = { value = "Small", is_editable = true }
        "mlflowTrackingServerName" = { value = "tracking-server", is_editable = true }
      }
    }
    "OnDemand EMR on EC2 Memory-Optimized" = {
      blueprint       = "EmrOnEc2"
      description     = "Enables you to create an additional memory optimized Amazon EMR on Amazon EC2"
      deployment_mode = "ON_DEMAND"
      parameter_overrides = {
        "emrRelease"            = { value = "emr-7.5.0", is_editable = true }
        "connectionDescription" = { value = "Spark connection for EMR EC2 cluster", is_editable = true }
        "clusterName"           = { value = "emr-ec2-cluster", is_editable = true }
        "primaryInstanceType"   = { value = "r6g.xlarge", is_editable = true }
        "coreInstanceType"      = { value = "r6g.xlarge", is_editable = true }
        "taskInstanceType"      = { value = "r6g.xlarge", is_editable = true }
      }
    }
    "OnDemand EMR on EC2 General-Purpose" = {
      blueprint       = "EmrOnEc2"
      description     = "Enables you to create an additional general purpose Amazon EMR on Amazon EC2"
      deployment_mode = "ON_DEMAND"
      parameter_overrides = {
        "emrRelease"            = { value = "emr-7.5.0", is_editable = true }
        "connectionDescription" = { value = "Spark connection for EMR EC2 cluster", is_editable = true }
        "clusterName"           = { value = "emr-ec2-cluster", is_editable = true }
        "primaryInstanceType"   = { value = "m6g.xlarge", is_editable = true }
        "coreInstanceType"      = { value = "m6g.xlarge", is_editable = true }
        "taskInstanceType"      = { value = "m6g.xlarge", is_editable = true }
      }
    }
    "OnDemand RedshiftServerless" = {
      blueprint       = "RedshiftServerless"
      description     = "Enables you to create an additional Amazon Redshift Serverless workgroup for your SQL workloads"
      deployment_mode = "ON_DEMAND"
      parameter_overrides = {
        "redshiftDbName"        = { value = "dev", is_editable = true }
        "redshiftMaxCapacity"   = { value = "512", is_editable = true }
        "redshiftWorkgroupName" = { value = "redshift-serverless-workgroup", is_editable = true }
        "redshiftBaseCapacity"  = { value = "128", is_editable = true }
        "connectionName"        = { value = "redshift.serverless", is_editable = true }
        "connectToRMSCatalog"   = { value = "false", is_editable = false }
      }
    }
    "OnDemand Catalog for Redshift Managed Storage" = {
      blueprint       = "LakehouseCatalog"
      description     = "Enables you to create additional catalogs in Amazon SageMaker Lakehouse for storing data in Redshift Managed Storage"
      deployment_mode = "ON_DEMAND"
      parameter_overrides = {
        "catalogName"        = { value = "", is_editable = true }
        "catalogDescription" = { value = "RMS catalog", is_editable = true }
      }
    }
    "OnDemand EMRServerless" = {
      blueprint       = "EmrServerless"
      description     = "Enables you to create an additional Amazon EMR Serverless application for running Spark workloads"
      deployment_mode = "ON_DEMAND"
      parameter_overrides = {
        "connectionDescription" = { value = "", is_editable = true }
        "connectionName"        = { value = "", is_editable = true }
        "releaseLabel"          = { value = "emr-7.5.0", is_editable = true }
      }
    }
    "Amazon Bedrock Chat Agent" = {
      blueprint       = "AmazonBedrockChatAgent"
      description     = "A configurable generative AI app with a conversational interface"
      deployment_mode = "ON_DEMAND"
    }
    "Amazon Bedrock Knowledge Base" = {
      blueprint       = "AmazonBedrockKnowledgeBase"
      description     = "A reusable component for providing your own data to apps"
      deployment_mode = "ON_DEMAND"
    }
    "Amazon Bedrock Guardrail" = {
      blueprint       = "AmazonBedrockGuardrail"
      description     = "A reusable component for implementing safeguards on model outputs"
      deployment_mode = "ON_DEMAND"
    }
    "Amazon Bedrock Function" = {
      blueprint       = "AmazonBedrockFunction"
      description     = "A reusable component for including dynamic information in model outputs"
      deployment_mode = "ON_DEMAND"
    }
    "Amazon Bedrock Flow" = {
      blueprint       = "AmazonBedrockFlow"
      description     = "A configurable generative AI workflow"
      deployment_mode = "ON_DEMAND"
    }
    "Amazon Bedrock Prompt" = {
      blueprint       = "AmazonBedrockPrompt"
      description     = "A reusable set of inputs that guide model outputs"
      deployment_mode = "ON_DEMAND"
    }
    "Amazon Bedrock Evaluation" = {
      blueprint       = "AmazonBedrockEvaluation"
      description     = "Enables evaluation features to compare Bedrock models"
      deployment_mode = "ON_DEMAND"
    }
    "QuickSight" = {
      blueprint       = "QuickSight"
      description     = "Amazon QuickSight for data visualization and business intelligence"
      deployment_mode = "ON_DEMAND"
    }
  }
  # Build the regional parameters for each blueprint (same VPC/subnets/S3 for all)
  regional_parameters = {
    (local.region) = {
      vpc_id     = local.vpc_id
      subnet_ids = local.subnet_ids
      s3_uri     = "s3://${module.domain.s3_bucket_name}"
    }
  }
}

resource "random_id" "project_suffix" {
  byte_length = 3
}

#####################################################################################
# 1. Domain Module
#    Creates the domain, Tooling blueprint, IAM roles, optional S3 bucket,
#    and model governance resources.
#    Demonstrates: Tooling blueprint integration (Req 9.3),
#                  model provisioning/consumption role config (Req 9.5),
#                  user role policy config (Req 9.6)
#####################################################################################

module "domain" {
  source = "../.."

  domain_name           = var.domain_name
  description           = var.domain_description
  vpc_id                = local.vpc_id
  subnet_ids            = local.subnet_ids
  s3_bucket_name        = var.s3_bucket_name
  user_role_policy_arns = var.user_role_policy_arns
  enable_sso            = var.enable_sso

  tags = local.common_tags
}

#####################################################################################
# 2. Blueprint Module (singular, invoked per blueprint)
#    Demonstrates: multiple blueprint invocations (Req 9.1),
#                  VPC configuration parameters (Req 9.4)
#####################################################################################

module "blueprints" {
  source   = "../../modules/blueprint"
  for_each = local.blueprint_configs

  domain_id      = module.domain.domain_id
  blueprint_name = each.value.blueprint_name

  # Only blueprints that provision compute/storage take VPC/subnet/S3 parameters.
  # QuickSight and Bedrock blueprints are enabled without regional parameters.
  regional_parameters = each.value.needs_regional_parameters ? local.regional_parameters : {}

  # Reuse roles created by the domain module
  manage_access_role_arn = module.domain.manage_access_role_arn
  provisioning_role_arn  = module.domain.provisioning_role_arn
  tags                   = local.common_tags
}

#####################################################################################
# 3. Project Profile Module (singular)
#    Demonstrates: blueprint dictionary composition (Req 9.2),
#                  Tooling blueprint integration from domain output (Req 9.3)
#####################################################################################

module "sql_analytics_project_profile" {
  count  = var.enable_sql_analytics ? 1 : 0
  source = "../../modules/project-profile"

  domain_id   = module.domain.domain_id
  name        = "SQL analytics"
  description = "Analyze your data in SageMaker Lakehouse using SQL"

  # Compose blueprints into the profile — Tooling is automatically included
  # and always first in the environment configurations
  blueprints = local.sql_analytics_blueprint_config

  blueprint_dependencies = [for k, bp in module.blueprints : bp.entity_id]

  depends_on = [module.blueprints]
}

module "generative_ai_project_profile" {
  count  = var.enable_generative_ai ? 1 : 0
  source = "../../modules/project-profile"

  domain_id   = module.domain.domain_id
  name        = "Generative AI application development"
  description = "Build generative AI applications powered by Amazon Bedrock"

  # Compose blueprints into the profile — Tooling is automatically included
  # and always first in the environment configurations
  blueprints = local.generative_ai_blueprint_config

  blueprint_dependencies = [for k, bp in module.blueprints : bp.entity_id]

  depends_on = [module.blueprints]
}

module "all_capabilities_project_profile" {
  count  = var.enable_all_capabilities ? 1 : 0
  source = "../../modules/project-profile"

  domain_id   = module.domain.domain_id
  name        = "All capabilities"
  description = "Analyze data and build machine learning and generative AI models and applications powered by Amazon Bedrock, Amazon EMR, AWS Glue, Amazon Athena, Amazon SageMaker AI and Amazon SageMaker Lakehouse"

  # Compose blueprints into the profile — Tooling is automatically included
  # and always first in the environment configurations
  blueprints = local.all_capabilities_blueprint_config

  blueprint_dependencies = [for k, bp in module.blueprints : bp.entity_id]

  depends_on = [module.blueprints]
}

module "create_project_from_project_profile_grant" {
  count          = (var.enable_sql_analytics || var.enable_all_capabilities || var.enable_generative_ai) ? 1 : 0
  source         = "../../modules/policy-grant-create-project"
  domain_id      = module.domain.domain_id
  domain_unit_id = module.domain.domain_root_unit_id
  project_profile_ids = concat(
    [for p in module.all_capabilities_project_profile : p.project_profile_id],
    [for p in module.sql_analytics_project_profile : p.project_profile_id],
    [for p in module.generative_ai_project_profile : p.project_profile_id],
  )
  all_users = true
  depends_on = [
    module.all_capabilities_project_profile,
    module.sql_analytics_project_profile,
    module.generative_ai_project_profile
  ]
}


#####################################################################################
# 4. Project Module
#    Creates a project from the profile with SSO user membership
#####################################################################################

module "project" {
  count  = (var.enable_sql_analytics || var.enable_all_capabilities || var.enable_generative_ai) ? 1 : 0
  source = "../../modules/project"

  domain_id           = module.domain.domain_id
  project_name        = local.project_name
  project_description = var.project_description
  // pick first available project profile
  project_profile_id = concat(module.all_capabilities_project_profile, module.sql_analytics_project_profile, module.generative_ai_project_profile)[0].project_profile_id

  depends_on = [module.create_project_from_project_profile_grant]
}

#####################################################################################
# 5. SSO User and Project Membership (Req 9.8)
#
# Mirrors the membership wiring used by the tooling-lite example: principals are
# grouped into project_owners / project_contributors sets, each accepting any
# combination of SSO users, SSO groups, IAM users, and IAM roles. IAM user ARNs
# are mapped to member_type IAM_USER and IAM role ARNs to IAM_ROLE. SSO users are
# registered as user profiles in the domain so they can be added as members.
#####################################################################################

locals {
  # The project is only created when at least one profile is enabled.
  project_enabled = var.enable_sql_analytics || var.enable_all_capabilities || var.enable_generative_ai

  # Union of every SSO user across the principal sets. Each unique user needs an
  # aws_datazone_user_profile created so they can be added as a project member.
  all_sso_users = toset(concat(
    var.project_owners.sso_users,
    var.project_contributors.sso_users,
  ))

  # Union of every SSO group across the principal sets. Each unique group needs an
  # awscc_datazone_group_profile created so it can be added as a project member.
  all_sso_groups = toset(concat(
    var.project_owners.sso_groups,
    var.project_contributors.sso_groups,
  ))

  # Union of every IAM user across the principal sets. Each unique IAM user needs
  # an aws_datazone_user_profile (user_type IAM_USER) created so it can be added
  # as a project member.
  all_iam_users = toset(concat(
    var.project_owners.iam_users,
    var.project_contributors.iam_users,
  ))
}

# Register each SSO user as a domain user profile.
resource "aws_datazone_user_profile" "sso_users" {
  for_each          = local.all_sso_users
  domain_identifier = module.domain.domain_id
  user_identifier   = each.key
  user_type         = "SSO_USER"
}

# Register each IAM user as a domain user profile so it can be added as a member.
resource "aws_datazone_user_profile" "iam_users" {
  for_each          = local.all_iam_users
  domain_identifier = module.domain.domain_id
  user_identifier   = each.key
  user_type         = "IAM_USER"
}

# Register each SSO group as a domain group profile so it can be added as a member.
resource "awscc_datazone_group_profile" "sso_groups" {
  for_each          = local.all_sso_groups
  domain_identifier = module.domain.domain_id
  group_identifier  = each.key
  status            = "ASSIGNED"
}

module "project_membership" {
  count  = local.project_enabled ? 1 : 0
  source = "../../modules/project-membership"

  domain_id            = module.domain.domain_id
  project_id           = module.project[0].project_id
  project_owners       = var.project_owners
  project_contributors = var.project_contributors

  depends_on = [
    aws_datazone_user_profile.sso_users,
    aws_datazone_user_profile.iam_users,
    awscc_datazone_group_profile.sso_groups,
  ]
}
