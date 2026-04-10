# Project Structure

```
├── main.tf                  # Root module: domain, IAM roles, S3 bucket, tooling blueprint, model governance
├── variables.tf             # Root module inputs (vpc_id, subnet_ids required; roles, bucket, SSO optional)
├── outputs.tf               # Root module outputs (domain info, role ARNs, blueprint IDs)
├── versions.tf              # Terraform and provider version constraints
├── VERSION                  # Semantic version file
├── .header.md               # Module description used by terraform-docs to generate README.md
├── README.md                # Auto-generated — do NOT edit manually (terraform-docs output)
│
├── modules/
│   ├── blueprint/           # Enable a single environment blueprint on a domain
│   │   ├── bootstrap/       # IAM role creation for provisioning + manage access
│   │   ├── main.tf, variables.tf, outputs.tf, versions.tf
│   │   └── .header.md
│   ├── project-profile/     # Compose blueprints into a deployable project profile
│   ├── project/             # Create a project from a project profile
│   ├── policy-grant/        # Manage DataZone policy grants
│   │   └── create_project/  # Grant create-project permission on domain units
│   └── metadata_form/       # Create metadata forms
│
├── examples/
│   └── quick-setup/         # End-to-end example: domain → blueprints → profile → project
│
├── tests/
│   └── 01_mandatory.tftest.hcl  # CI test with mock providers (plan + apply)
│
├── .config/                 # Tool configurations
│   ├── .tflint.hcl          # TFLint rules (snake_case, docs, pinned sources)
│   ├── .tfsec.yml           # tfsec config
│   ├── .tfsec/              # Custom tfsec checks (IMDSv2, SG rules, launch config)
│   ├── .checkov.yml         # Checkov config
│   ├── .terraform-docs.yaml # terraform-docs config (generates README.md from .header.md)
│   └── .mdlrc              # Markdown lint config
│
└── .project_automation/     # CI/CD pipeline scripts
    ├── static_tests/        # Lint, validate, security scan, docs check
    ├── functional_tests/    # Integration tests
    ├── publication/         # Module publishing
    └── provision/           # Provisioning automation
```

## Conventions
- Each module and example follows standard Terraform structure: `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`
- Every module/example has a `.header.md` that terraform-docs uses to generate `README.md` — edit `.header.md`, not `README.md`
- Naming: snake_case for all Terraform identifiers (enforced by tflint)
- All variables must be typed and documented (enforced by tflint)
- All outputs must have descriptions (enforced by tflint)
- Input validation blocks are used extensively on variables (regex patterns for ARNs, VPC IDs, subnet IDs, bucket names)
- Conditional resource creation uses `count` driven by nullable variables (e.g., `count = var.role_arn == null ? 1 : 0`)
- Tags: all resources get `var.tags` merged with module-specific tags (`ManagedBy = "Terraform"`, `Purpose = ...`)
- The `awscc` provider is used when the `aws` provider lacks support (project profiles, projects, policy grants, blueprint configs with global parameters)
- Security suppressions (checkov, tfsec) are inline-commented with justification
