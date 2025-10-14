# Terraform and Provider Version Constraints
# Ensures compatibility with SageMaker Unified Studio resources

terraform {
  required_version = ">= 1.5"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.11.0"
    }
    awscc = {
      source  = "hashicorp/awscc"
      version = ">= 1.50.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9"
    }
  }
}
