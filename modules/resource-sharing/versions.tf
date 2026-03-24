# Terraform and Provider Version Constraints for Resource Sharing Module

terraform {
  required_version = ">= 1.5"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.37.0"
    }
  }
}
