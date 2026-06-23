terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.51.0"
    }
    awscc = {
      source  = "hashicorp/awscc"
      version = ">= 1.89.0"
    }
  }
}