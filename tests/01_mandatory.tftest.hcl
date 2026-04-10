## Mandatory CI test — mock providers, no real AWS resources.
## Validates the full quick-setup module graph without needing credentials.

mock_provider "aws" {
  mock_data "aws_subnet" {
    defaults = {
      vpc_id = "vpc-abc123"
    }
  }
  mock_data "aws_caller_identity" {
    defaults = {
      account_id = "123456789012"
    }
  }
  mock_data "aws_region" {
    defaults = {
      name = "us-east-1"
      id   = "us-east-1"
    }
  }
  mock_data "aws_iam_roles" {
    defaults = {
      arns = []
    }
  }
  mock_resource "aws_iam_role" {
    defaults = {
      arn = "arn:aws:iam::123456789012:role/mock-role"
    }
  }
  mock_resource "aws_iam_policy" {
    defaults = {
      arn = "arn:aws:iam::123456789012:policy/mock-policy"
    }
  }
  mock_resource "aws_datazone_domain" {
    defaults = {
      arn        = "arn:aws:datazone:us-east-1:123456789012:domain/dzd-mock123"
      id         = "dzd-mock123"
      portal_url = "https://dzd-mock123.datazone.us-east-1.on.aws"
    }
  }
  mock_data "aws_datazone_domain" {
    defaults = {
      root_domain_unit_id = "mock-root-unit-id"
    }
  }
  mock_data "aws_datazone_environment_blueprint" {
    defaults = {
      id = "mock-blueprint-id"
    }
  }
}
mock_provider "awscc" {
  mock_data "awscc_datazone_environment_blueprint_configuration" {
    defaults = {
      enabled_regions = ["us-east-1"]
    }
  }
}
mock_provider "random" {}
mock_provider "time" {}
mock_provider "null" {}

run "mandatory_plan_basic" {
  command = plan
  module {
    source = "./examples/quick-setup"
  }

  variables {
    vpc_id     = "vpc-abc123"
    subnet_ids = ["subnet-abc123"]
  }
}

run "mandatory_apply_basic" {
  command = apply
  module {
    source = "./examples/quick-setup"
  }

  variables {
    vpc_id     = "vpc-abc123"
    subnet_ids = ["subnet-abc123"]
  }
}
