# Product Overview

This is a Terraform module for deploying Amazon SageMaker Unified Studio domains backed by AWS DataZone (V2).

The root module creates:
- A SageMaker Unified Studio (V2) domain
- IAM roles (domain execution, domain service, query execution, provisioning, manage access) — auto-created unless user-provided
- The Tooling blueprint — enabled and configured with VPC, subnet, and S3 parameters
- An S3 bucket for tooling environment storage (optional)
- Model governance resources (project profile + project for Bedrock generative AI)

Role creation follows a 3-tier resolution: user-provided ARN → pre-existing role discovered in AWS → Terraform-managed role.

Sub-modules handle specific resource types:
- `modules/blueprint` — Enable an environment blueprint on a domain
- `modules/project-profile` — Compose blueprints into a deployable project profile
- `modules/project` — Create a project from a project profile
- `modules/policy-grant` — Manage DataZone policy grants
- `modules/metadata_form` — Create metadata forms

Only `vpc_id` and `subnet_ids` are required inputs. All IAM roles, the S3 bucket, and the domain name are auto-generated when not provided.
