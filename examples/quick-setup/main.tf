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
    (var.enable_generative_ai || var.enable_all_capabilities) ? {
      amazon_bedrock_generative_ai = {
        blueprint_name = "AmazonBedrockGenerativeAI"
      }
      amazon_bedrock_chat_agent = {
        blueprint_name = "AmazonBedrockChatAgent"
      }
      amazon_bedrock_evaluation = {
        blueprint_name = "AmazonBedrockEvaluation"
      }
      amazon_bedrock_flow = {
        blueprint_name = "AmazonBedrockFlow"
      }
      amazon_bedrock_function = {
        blueprint_name = "AmazonBedrockFunction"
      }
      amazon_bedrock_guardrail = {
        blueprint_name = "AmazonBedrockGuardrail"
      }
      amazon_bedrock_knowledge_base = {
        blueprint_name = "AmazonBedrockKnowledgeBase"
      }
      amazon_bedrock_prompt = {
        blueprint_name = "AmazonBedrockPrompt"
      }
    } : {},
    (var.enable_sql_analytics || var.enable_all_capabilities) ? {
      lakehouse_database = {
        blueprint_name = "DataLake"
      }
      lakehouse_catalog = {
        blueprint_name = "LakehouseCatalog"
      }
      redshift_serverless = {
        blueprint_name = "RedshiftServerless"
      }
    } : {},
    (var.enable_all_capabilities) ? {
      emr_serverless = {
        blueprint_name = "EmrServerless"
      }
      emr_on_ec2 = {
        blueprint_name = "EmrOnEc2"
      }
      ml_experiments = {
        blueprint_name = "MLExperiments"
      }
      workflows = {
        blueprint_name = "Workflows"
      }
    } : {},
  )

  sql_analytics_blueprint_config = {
    "DataLake" = {
      deployment_mode = "ON_CREATE"
      parameter_overrides = {
        "glueDbName" = {
          value       = "glue_db"
          is_editable = true
        }
      }
    }
    "RedshiftServerless" = {
      deployment_mode = "ON_CREATE"
      parameter_overrides = {
        "connectToRMSCatalog" = {
          value       = "true"
          is_editable = false
        }
        "redshiftDbName" = {
          value       = "dev"
          is_editable = true
        }
        "redshiftMaxCapacity" = {
          value       = "512"
          is_editable = false
        }
      }
    }
    "LakehouseCatalog" = {
      deployment_mode = "ON_DEMAND"
      parameter_overrides = {
        "catalogDescription" = {
          value       = "RMS catalog"
          is_editable = true
        }
        "catalogName" = {
          value       = ""
          is_editable = true
        }
      }
    }
    "RedshiftServerless" = {
      deployment_mode = "ON_DEMAND"
      parameter_overrides = {
        "connectionName" = {
          value       = "redshift.serverless"
          is_editable = true
        }
        "connectToRMSCatalog" = {
          value       = "false"
          is_editable = false
        }
        "redshiftBaseCapacity" = {
          value       = "128"
          is_editable = true
        }
        "redshiftDbName" = {
          value       = "dev"
          is_editable = true
        }
        "redshiftMaxCapacity" = {
          value       = "512"
          is_editable = true
        }
        "redshiftWorkgroupName" = {
          value       = "redshift-serverless-workgroup"
          is_editable = true
        }
      }
    }
  }

  generative_ai_blueprint_config = {
    "AmazonBedrockEvaluation" = {
      deployment_mode = "ON_DEMAND"
    }
    "AmazonBedrockPrompt" = {
      deployment_mode = "ON_DEMAND"
    }
    "AmazonBedrockFlow" = {
      deployment_mode = "ON_DEMAND"
    }
    "AmazonBedrockFunction" = {
      deployment_mode = "ON_DEMAND"
    }
    "AmazonBedrockGuardrail" = {
      deployment_mode = "ON_DEMAND"
    }
    "AmazonBedrockKnowledgeBase" = {
      deployment_mode = "ON_DEMAND"
    }
    "AmazonBedrockChatAgent" = {
      deployment_mode = "ON_DEMAND"
    }
  }

  all_capabilities_blueprint_config = merge(local.sql_analytics_blueprint_config, local.generative_ai_blueprint_config)
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

  regional_parameters = local.regional_parameters

  # Reuse roles created by the domain module
  manage_access_role_arn = module.domain.manage_access_role_arn
  provisioning_role_arn  = module.domain.provisioning_role_arn
  tags                   = local.common_tags

  depends_on = [module.domain]
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

  depends_on = [module.blueprints]
}

module "create_project_from_project_profile_grant" {
  count  = (var.enable_sql_analytics || var.enable_all_capabilities || var.enable_generative_ai) ? 1 : 0
  source         = "../../modules/policy-grant/create_project"
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
#####################################################################################

resource "aws_datazone_user_profile" "sso_users" {
  for_each          = toset(var.sso_users)
  domain_identifier = module.domain.domain_id
  user_identifier   = each.key
  user_type         = "SSO_USER"
}

resource "awscc_datazone_project_membership" "project_membership" {
  for_each           = toset(var.sso_users)
  domain_identifier  = module.domain.domain_id
  project_identifier = module.project[0].project_id
  member = {
    user_identifier = each.key
  }
  designation = "PROJECT_OWNER"
}
