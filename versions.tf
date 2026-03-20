# Terraform and Provider Version Constraints
# Ensures compatibility with SageMaker Unified Studio resources

terraform {
  required_version = ">= 1.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.28.0"
    }
    awscc = {
      source  = "hashicorp/awscc"
      version = ">= 1.68.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.8.1"
    }
  }
}
