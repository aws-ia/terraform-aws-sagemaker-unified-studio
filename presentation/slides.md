---
marp: true
theme: default
paginate: true
backgroundColor: #1a1a2e
color: #e0e0e0
style: |
  section {
    font-family: 'Helvetica Neue', Arial, sans-serif;
  }
  h1, h2, h3 {
    color: #ff9900;
  }
  section.lead h1 {
    font-size: 2.5em;
    color: #ff9900;
  }
  section.lead h2 {
    color: #ccc;
  }
  section.lead p {
    color: #888;
  }
  code {
    background: #232f3e;
    color: #ff9900;
    padding: 0.1em 0.3em;
    border-radius: 3px;
  }
  pre {
    background: #0d1117;
    border: 1px solid #333;
    border-radius: 6px;
    padding: 0.8em;
    overflow: auto;
  }
  pre code {
    background: transparent;
    font-family: 'SF Mono', 'Fira Code', 'Consolas', monospace;
    font-size: 0.85em;
    line-height: 1.5;
    padding: 0;
  }
  /* GitHub Dark syntax highlighting */
  .hljs { color: #c9d1d9; }
  .hljs-keyword, .hljs-selector-tag { color: #ff7b72; }
  .hljs-string, .hljs-attr { color: #a5d6ff; }
  .hljs-title, .hljs-function { color: #d2a8ff; }
  .hljs-comment { color: #8b949e; font-style: italic; }
  .hljs-number, .hljs-literal { color: #79c0ff; }
  .hljs-built_in { color: #ffa657; }
  .hljs-type, .hljs-params { color: #ffa657; }
  .hljs-variable { color: #ffa657; }
  .hljs-symbol { color: #7ee787; }
  .hljs-meta { color: #8b949e; }
  .hljs-addition { color: #aff5b4; background: #033a16; }
  .hljs-deletion { color: #ffdcd7; background: #67060c; }
  table {
    font-size: 0.75em;
  }
  th {
    background: #232f3e;
    color: #ff9900;
  }
  td, th {
    border: 1px solid #444;
    padding: 0.4em 0.8em;
  }
  a {
    color: #ff9900;
  }
  .columns {
    display: flex;
    gap: 2em;
  }
  .columns > div {
    flex: 1;
  }
  blockquote {
    border-left: 4px solid #ff9900;
    padding-left: 1em;
    color: #aaa;
    font-style: italic;
  }
  footer {
    color: #555;
  }
---

<!-- _class: lead -->

# SageMaker Unified Studio
## Infrastructure as Code with Terraform



---

# Agenda (30 min)

1. **The Problem** — Why Terreaform IaC for Sagemaker Unified Studio? *(5 min)*
2. **Architecture** — Module design & resource map *(5 min)*
3. **Key Design Decisions** — 3-tier role resolution & more *(5 min)*
4. **Live Walkthrough** — Quick-setup example *(7 min)*
5. **Terraform vs CloudFormation** — Differentiators *(3 min)*
6. **Testing Strategy** — Unit + E2E *(3 min)*
7. **Wrap-up & Q&A** *(2 min)*

---

<!-- _class: lead -->

# 1
## The Problem
Why Infrastructure as Code for SageMaker Unified Studio?

---

# Console Quick-Setup is Great… for One Account

The console wizard creates **20+ interdependent resources**:

- A **DataZone domain**
- **5+ IAM roles** (domain execution, service, query, provisioning, manage access)
- **S3 buckets** for tooling storage
- **Environment blueprints** (Tooling, Bedrock, Lakehouse, etc.)
- **Project profiles** and **projects**
- **Policy grants**

> Click, click, click… done. But only for *one* account.

---

# But in the Real World…

- Deploy across **dev → staging → prod** accounts
- Need **repeatable, auditable** infrastructure
- CloudFormation templates exist but are **monolithic** — all or nothing
- **No official Terraform support** — customers using Terraform were stuck
- Manual setup = **drift, inconsistency, human error**

---

# The Gap

<div class="columns">
<div>

### What Existed
- Console wizard
- Monolithic CFN templates
- No Terraform module

</div>
<div>

### What Customers Needed
- Composable modules
- Multi-account support
- Terraform-native workflow
- Idempotent, safe re-runs

</div>
</div>

---

<!-- _class: lead -->

# 2
## Architecture
Module design & resource map

---

# Module Hierarchy

```
terraform-aws-sagemaker-unified-studio/
├── main.tf                ← Root module (domain + IAM + S3 + Tooling)
├── modules/
│   ├── blueprint/         ← Enable any environment blueprint
│   │   └── bootstrap/     ← Provisioning & manage-access roles
│   ├── project-profile/   ← Compose blueprints into profiles
│   ├── project/           ← Create projects from profiles
│   ├── policy-grant/      ← DataZone policy grants
│   ├── metadata_form/     ← Metadata forms
│   ├── organization/      ← Domain organizational units
│   └── resource-sharing/  ← Cross-account sharing
└── examples/
    └── quick-setup/       ← End-to-end example
```

---

# What the Root Module Creates

| Resource | Provider | Purpose |
|---|---|---|
| DataZone Domain | `aws` | SageMaker Unified Studio domain |
| Domain Execution Role | `aws` | Domain-level operations |
| Domain Service Role | `aws` | Service-linked operations |
| Query Execution Role | `aws` | Tooling blueprint queries |
| S3 Bucket | `aws` | Tooling environment storage |
| Tooling Blueprint | `awscc` | Base environment blueprint |
| Model Governance | `awscc` | Bedrock model governance |

---

# Dual Provider Strategy

<div class="columns">
<div>

### `aws` Provider
- IAM roles & policies
- S3 bucket + config
- DataZone domain
- Mature, stable resources

</div>
<div>

### `awscc` Provider
- Environment blueprints
- Project profiles
- Projects
- Day-1 CloudControl coverage

</div>
</div>

> Why both? Some DataZone resources are **only** available via Cloud Control API.

---

# Data Flow Between Modules

```
┌─────────────┐     outputs      ┌──────────────┐
│ Root Module  │ ──────────────→  │  Blueprint   │
│  (Domain)    │  domain_id       │   Module     │
│              │  role ARNs       │  (per each)  │
└─────────────┘                   └──────┬───────┘
                                         │ entity_id
                                         ▼
                                  ┌──────────────┐
                                  │   Project    │
                                  │   Profile    │
                                  └──────┬───────┘
                                         │ profile_id
                                         ▼
                                  ┌──────────────┐
                                  │   Project    │
                                  └──────────────┘
```

Each module consumes outputs from the previous stage.

---

<!-- _class: lead -->

# 3
## Key Design Decisions
3-tier role resolution, idempotency, and safety

---

# 3-Tier Role Resolution

```hcl
# Resolution order:
# 1. User-provided ARN  →  use as-is
# 2. Pre-existing role  →  discovered via data source
# 3. Auto-create        →  Terraform-managed resource

domain_execution_role_arn = (
  var.domain_execution_role_arn != null
    ? var.domain_execution_role_arn                               # Tier 1
    : length(data.aws_iam_roles.domain_execution_role.arns) > 0
      ? tolist(data.aws_iam_roles.domain_execution_role.arns)[0]  # Tier 2
      : aws_iam_role.domain_execution[0].arn                      # Tier 3
)
```

Safe to run in accounts that **already have** the standard roles.

---

# Why 3 Tiers?

| Scenario | Tier | Behavior |
|---|---|---|
| Enterprise with custom roles | 1 | Pass ARN, skip creation |
| Account with console-created roles | 2 | Discover & reuse |
| Fresh account, no roles | 3 | Auto-create everything |

**Zero manual pre-work required** in any scenario.

---

# Blueprint Composition — Toggle with Booleans

```hcl
variable "enable_sql_analytics"    { default = false }
variable "enable_generative_ai"    { default = false }
variable "enable_all_capabilities" { default = false }

# Blueprints are dynamically composed via merge()
blueprint_configs = merge(
  var.enable_generative_ai ? {
    amazon_bedrock_chat_agent = { blueprint_name = "AmazonBedrockChatAgent" }
    amazon_bedrock_flow       = { blueprint_name = "AmazonBedrockFlow" }
    # ... 5 more Bedrock blueprints
  } : {},
  var.enable_sql_analytics ? {
    lakehouse_catalog   = { blueprint_name = "LakehouseCatalog" }
    redshift_serverless = { blueprint_name = "RedshiftServerless" }
  } : {},
)
```

---

# Safety by Design

- **S3 bucket:** `force_destroy = false` — prevents accidental data loss
- **Versioning:** enabled on the tooling bucket
- **Encryption:** server-side encryption configured
- **Public access:** blocked at bucket level
- **Logging:** bucket logging enabled
- **Cleanup:** documented 2-step destroy process

```bash
# Empty the bucket first
aws s3 rm s3://<your-tooling-bucket-name> --recursive
# Then destroy
terraform destroy
```

---

# Minimal Required Inputs

```hcl
module "domain" {
  source = "path/to/this/module"

  vpc_id     = "vpc-0abc123def456"
  subnet_ids = ["subnet-0aaa111", "subnet-0bbb222"]
}
```

Only **2 required variables**. Everything else has smart defaults.

Domain name, IAM roles, S3 bucket — all auto-generated when omitted.

---

<!-- _class: lead -->

# 4
## Live Walkthrough
The quick-setup example end-to-end

---

# Quick-Setup: Domain + Blueprints

```hcl
# examples/quick-setup/main.tf

module "domain" {
  source      = "../.."
  domain_name = var.domain_name
  vpc_id      = local.vpc_id
  subnet_ids  = local.subnet_ids
  enable_sso  = var.enable_sso
  tags        = local.common_tags
}

module "blueprints" {
  source   = "../../modules/blueprint"
  for_each = local.blueprint_configs

  domain_id              = module.domain.domain_id
  blueprint_name         = each.value.blueprint_name
  regional_parameters    = local.regional_parameters
  manage_access_role_arn = module.domain.manage_access_role_arn
  provisioning_role_arn  = module.domain.provisioning_role_arn
}
```

---

# Quick-Setup: Profile → Project

```hcl
module "sql_analytics_project_profile" {
  source     = "../../modules/project-profile"
  domain_id  = module.domain.domain_id
  name       = "SQL analytics"
  blueprints = local.sql_analytics_blueprint_config

  blueprint_dependencies = [
    for k, bp in module.blueprints : bp.entity_id
  ]
}

module "project" {
  source             = "../../modules/project"
  domain_id          = module.domain.domain_id
  project_name       = local.project_name
  project_profile_id = module.sql_analytics_project_profile[0].project_profile_id
}
```

---

# Deploy in 3 Commands

```bash
# 1. Configure
cp terraform.tfvars.example terraform.tfvars
# Edit: vpc_id, subnet_ids, enable_sql_analytics = true

# 2. Initialize
terraform init

# 3. Apply
terraform apply
```

**Result:**
✅ Domain created → ✅ IAM roles resolved (3-tier) → ✅ Tooling blueprint
✅ SQL Analytics blueprints → ✅ Project profile → ✅ Project → ✅ Domain URL

---

# Toggle Capabilities

```hcl
# terraform.tfvars

# Start with SQL analytics only
enable_sql_analytics    = true
enable_generative_ai    = false
enable_all_capabilities = false

# Later, add Generative AI — just flip the boolean
enable_generative_ai    = true

# Or go all-in
enable_all_capabilities = true
```

`terraform plan` shows **exactly** what will change before you apply.

---

# Key Outputs

```
Outputs:

domain_id          = "dzd_abc123def456"
domain_url         = "https://us-east-1.console.aws.amazon.com/..."
domain_arn         = "arn:aws:datazone:us-east-1:123456789012:domain/..."
s3_bucket_name     = "sagemaker-unified-studio-tooling-abc123"
provisioning_role  = "arn:aws:iam::123456789012:role/AmazonSageMaker..."
tooling_blueprint  = "bp-abc123"
```

---

<!-- _class: lead -->

# 5
## Terraform vs CloudFormation
The differentiators

---

# Side-by-Side Comparison

| Aspect | CloudFormation | This Terraform Module |
|---|---|---|
| **Modularity** | Monolithic stack | Composable sub-modules |
| **Role handling** | Pre-create or hardcode | 3-tier auto-resolution |
| **Multi-account** | Copy/paste stacks | Different tfvars per account |
| **State** | Stack-level, opaque | `plan` shows exact diff |
| **Existing infra** | Can't adopt roles | Discovers & reuses roles |
| **Testing** | Manual validation | Built-in `terraform test` |
| **Drift** | Drift detect (limited) | `plan` on every run |

---

# Multi-Account Deployment

```
environments/
├── dev/
│   └── terraform.tfvars      # dev VPC, dev account
├── staging/
│   └── terraform.tfvars      # staging VPC, staging account
└── prod/
    └── terraform.tfvars      # prod VPC, prod account
```

```bash
# Deploy to any environment — same module, different config
terraform apply -var-file=environments/prod/terraform.tfvars
```

---

<!-- _class: lead -->

# 6
## Testing Strategy
Unit tests + End-to-end tests

---

# Unit Tests with `terraform test`

```hcl
# tests/iam_roles.tftest.hcl

run "verify_domain_execution_role" {
  command = plan
  assert {
    condition     = aws_iam_role.domain_execution[0].name != ""
    error_message = "Domain execution role must have a name"
  }
}

run "verify_3tier_resolution_with_existing_role" {
  command = plan
  variables {
    domain_execution_role_arn = "arn:aws:iam::123:role/MyRole"
  }
  assert {
    condition = local.domain_execution_role_arn == var.domain_execution_role_arn
    error_message = "Should use user-provided ARN (Tier 1)"
  }
}
```

---

# Test Coverage

| Test File | What It Validates |
|---|---|
| `domain.tftest.hcl` | Domain creation & naming |
| `iam_roles.tftest.hcl` | 3-tier role resolution logic |
| `blueprint.tftest.hcl` | Blueprint enable/disable |
| `project_profile.tftest.hcl` | Profile composition |
| `examples.tftest.hcl` | Quick-setup plan validation |

---

# E2E Tests

```bash
# tests/e2e/run-e2e.sh — full lifecycle orchestration

Step 1: Deploy domain            (01-root-domain/)
Step 2: Enable blueprints        (02-blueprints/)
Step 3: Create project profile   (03-project-profile/)
Step 4: Validation tests         (API checks, resource existence)
Step 5: Destroy all              (reverse order)
```

Most tested path: the **quick-setup example** — exercises all modules end-to-end.

---

<!-- _class: lead -->

# 7
## Wrap-Up

---

# Key Takeaways

- **Modular** — Use only the sub-modules you need
- **Safe** — 3-tier role resolution works in any account state
- **Simple** — 2 required inputs, everything else has defaults
- **Tested** — Unit tests + E2E with `terraform test`
- **Composable** — Toggle capabilities with booleans
- **Open source** — `aws-ia/terraform-aws-sagemaker-unified-studio`

---

# Requirements

| Dependency | Version |
|---|---|
| Terraform | `>= 1.7` |
| AWS Provider | `>= 6.37.0` |
| AWSCC Provider | `>= 1.76.0` |
| Random Provider | `>= 3.8.1` |

---

<!-- _class: lead -->

# Thank You
## Questions?

`github.com/aws-ia/terraform-aws-sagemaker-unified-studio`
