# SageMaker Unified Studio MVP Example

This example provides a complete **Minimum Viable Product (MVP)** deployment of Amazon SageMaker Unified Studio using Terraform. It combines domain creation, IAM role setup, blueprint configuration, and project creation in a single, unified configuration.

## What This Example Creates

This MVP example creates all the resources from both the `basic-domain` and `single-account-project` examples:

### Core Infrastructure
- **SageMaker Unified Studio Domain** - The main domain for your data and ML platform
- **IAM Roles** - All required roles (domain execution, SageMaker manage access, SageMaker provisioning)
- **Environment Blueprint Configurations** - Essential blueprints for data lake, data warehouse, and ML workloads
- **DataZone Project** - A working project ready for use
- **S3 Bucket** - Secure storage for tooling environments with versioning and encryption

### Blueprints Enabled by Default
- **Default Data Lake** - For data catalog and lake functionality
- **Default Data Warehouse** - For analytics workloads  
- **Default SageMaker** - For ML workloads and experimentation

## Prerequisites

1. **AWS CLI** configured with appropriate permissions
2. **Terraform** >= 1.5 installed
3. **AWS Account** with SageMaker Unified Studio available in your region

### Required AWS Permissions
Your AWS credentials need permissions for:
- DataZone (domain, project, blueprint management)
- IAM (role creation and policy attachment)
- S3 (bucket creation and configuration)
- EC2 (VPC and subnet access for default networking)

## Quick Start

### 1. Configure Variables
```bash
brew install terraform-docs
```

or

```bash
brew install terraform-docs/tap/terraform-docs
```

Windows users can install using [Scoop]:

```bash
scoop bucket add terraform-docs https://github.com/terraform-docs/scoop-bucket
scoop install terraform-docs
```

or [Chocolatey]:

```bash
choco install terraform-docs
```

Stable binaries are also available on the [releases] page. To install, download the
binary for your platform from "Assets" and place this into your `$PATH`:

```bash
curl -Lo ./terraform-docs.tar.gz https://github.com/terraform-docs/terraform-docs/releases/download/v0.20.0/terraform-docs-v0.20.0-$(uname)-amd64.tar.gz
tar -xzf terraform-docs.tar.gz
chmod +x terraform-docs
mv terraform-docs /usr/local/bin/terraform-docs
```

**NOTE:** Windows releases are in `ZIP` format.

The latest version can be installed using `go install` or `go get`:

```bash
# go1.17+
go install github.com/terraform-docs/terraform-docs@v0.20.0
```

```bash
# go1.16
GO111MODULE="on" go get github.com/terraform-docs/terraform-docs@v0.20.0
```

**NOTE:** please use the latest Go to do this, minimum `go1.16` is required.

This will put `terraform-docs` in `$(go env GOPATH)/bin`. If you encounter the error
`terraform-docs: command not found` after installation then you may need to either add
that directory to your `$PATH` as shown [here] or do a manual installation by cloning
the repo and run `make build` from the repository which will put `terraform-docs` in:

```bash
$(go env GOPATH)/src/github.com/terraform-docs/terraform-docs/bin/$(uname | tr '[:upper:]' '[:lower:]')-amd64/terraform-docs
```

## Usage

### Running the binary directly

To run and generate documentation into README within a directory:

```bash
# Create project profile (example)
aws datazone create-project-profile \
  --domain-identifier dzd_abc123xyz \
  --name 'Basic Analytics' \
  --environment-configurations file://profile-config.json

# Add project member (example)  
aws datazone create-project-membership \
  --domain-identifier dzd_abc123xyz \
  --project-identifier p123abc456def \
  --member UserIdentifier=user@example.com \
  --designation PROJECT_OWNER
```

## Architecture

```
┌─────────────────────────────────────────────────┐
│                 MVP Architecture                │
├─────────────────────────────────────────────────┤
│  SageMaker Unified Studio Domain               │
│  ├── IAM Roles (3)                            │
│  │   ├── Domain Execution Role                │
│  │   ├── SageMaker Manage Access Role         │
│  │   └── SageMaker Provisioning Role          │
│  │                                            │
│  ├── Environment Blueprints (3)               │
│  │   ├── Default Data Lake                    │
│  │   ├── Default Data Warehouse               │
│  │   └── Default SageMaker                    │
│  │                                            │
│  ├── Project                                  │
│  │   └── Ready for environments               │
│  │                                            │
│  └── Supporting Infrastructure                │
│      ├── S3 Bucket (versioned + encrypted)   │
│      └── VPC/Subnet Integration               │
└─────────────────────────────────────────────────┘
```

## File Structure

```
mvp/
├── main.tf                   # Main configuration combining both examples
├── variables.tf              # All variables from both examples  
├── outputs.tf                # Combined outputs
├── terraform.tfvars.example  # Example configuration
├── validate.sh              # Validation script
└── README.md                # This file
```

## Validation Script

The `validate.sh` script performs comprehensive validation:

- ✅ **AWS CLI Access** - Verifies authentication and account
- ✅ **IAM Roles** - Confirms all roles are created
- ✅ **Domain Status** - Checks domain is AVAILABLE
- ✅ **Blueprint Configuration** - Validates enabled blueprints
- ✅ **Project Status** - Confirms project is ACTIVE
- ✅ **S3 Bucket** - Verifies bucket, versioning, and encryption
- ✅ **Network Configuration** - Checks VPC and subnet access

## Next Steps After MVP Deployment

1. **Manual Configuration**:
   - Create project profiles via AWS Console
   - Add user memberships to projects
   - Configure environment parameters

2. **Create Environments**:
   - Use the enabled blueprints to create environments
   - Configure data lake, warehouse, or ML environments

3. **Add Users**:
   - Set up SSO users in IAM Identity Center (if enabled)
   - Assign users to projects with appropriate roles

4. **Explore Features**:
   - Data catalog and discovery
   - Environment management
   - ML experiment tracking

## Troubleshooting

### Common Issues

1. **Domain Creation Fails**:
   - Verify SageMaker Unified Studio is available in your region
   - Check IAM permissions for DataZone service

2. **Blueprint Configuration Fails**:
   - Ensure S3 bucket creation succeeded
   - Verify VPC and subnet accessibility

3. **Project Creation Fails**:
   - Confirm domain is in AVAILABLE status
   - Check blueprint configurations are enabled

### Getting Help

- Run `./validate.sh` for detailed status information
- Check AWS CloudFormation events for detailed error messages
- Verify AWS CLI permissions with `aws sts get-caller-identity`

## Cost Considerations

This MVP creates:
- SageMaker Unified Studio domain (pay-per-use)
- IAM roles (no cost)
- S3 bucket (minimal storage cost)
- No running compute resources (cost only when environments are created)

The base infrastructure has minimal ongoing costs, with primary charges occurring when you create and use environments.

## Cleanup

To destroy all resources:

Empty & delete the S3 bucket (must be empty to delete): my-analytics-project-tooling-<alphanumerics>

```bash
# Use standard terraform destroy (no wrapper script needed)
terraform destroy
```

⚠️ **Warning**: This will delete all resources including the domain and any data stored in S3 buckets.

---

**Ready to get started?** Follow the Quick Start guide above to deploy your SageMaker Unified Studio MVP!