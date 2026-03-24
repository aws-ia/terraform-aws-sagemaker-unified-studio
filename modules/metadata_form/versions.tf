terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.37.0"
    }
    awscc = {
      source  = "hashicorp/awscc"
      version = ">= 1.76.0"
    }
  }
}