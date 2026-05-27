terraform {
  required_version = ">= 1.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.46.0"
    }
    awscc = {
      source  = "hashicorp/awscc"
      version = ">= 1.85.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.8.1"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.13.1"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.4"
    }
  }
}
