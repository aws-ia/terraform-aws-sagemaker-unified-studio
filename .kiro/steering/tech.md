# Tech Stack

## Core
- Terraform >= 1.7
- HCL (HashiCorp Configuration Language)

## Providers
- `hashicorp/aws` >= 6.37.0 — primary AWS resources (IAM, S3, DataZone)
- `hashicorp/awscc` >= 1.76.0 — AWS Cloud Control resources (project profiles, projects, policy grants, blueprint configs with global parameters)
- `hashicorp/time` >= 0.13.1 — propagation delays
- `hashicorp/random` >= 3.8.1 — unique name suffixes

## Static Analysis & Linting
- `tflint` with AWS ruleset (v0.22.1) — enforces snake_case naming, typed variables, documented outputs/variables, pinned sources
- `tfsec` — security scanning with custom checks in `.config/.tfsec/`
- `checkov` — Terraform security/compliance (config in `.config/.checkov.yml`)
- `mdl` — Markdown linting for `.header.md` files
- `terraform-docs` — auto-generates `README.md` from `.header.md` + module inputs/outputs

## Testing
- Terraform native tests (`*.tftest.hcl` in `tests/`) using mock providers
- Tests use `mock_provider` blocks — no real AWS credentials needed for CI
- Test file: `tests/01_mandatory.tftest.hcl` runs plan + apply against `examples/quick-setup`

## Common Commands

```bash
# Initialize
terraform init

# Validate syntax
terraform validate

# Run linting
tflint --init --config .config/.tflint.hcl
tflint --force --config .config/.tflint.hcl

# Security scan
tfsec . --config-file .config/.tfsec.yml --custom-check-dir .config/.tfsec

# Checkov
checkov --config-file .config/.checkov.yml

# Run tests (mock providers, no AWS creds needed)
terraform test

# Generate docs (run from root, examples/*, or modules/*)
terraform-docs --config .config/.terraform-docs.yaml --lockfile=false .

# Run all static tests at once
bash -c 'export PROJECT_PATH=$(pwd) && export PROJECT_TYPE_PATH=$(pwd) && tail -n +6 .project_automation/static_tests/static_tests.sh | bash'

# Pre-commit (runs static tests)
pre-commit run --all-files
```
