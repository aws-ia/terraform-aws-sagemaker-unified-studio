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
# Copy the example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit the configuration
vi terraform.tfvars
```

Key variables to customize:
```hcl
# AWS Configuration
aws_region = "us-west-2"  # Your preferred region

# Domain Configuration  
domain_name = "my-unified-studio-mvp"

# Project Configuration
project_name = "my-analytics-project"

# Blueprint Configuration (all recommended for MVP)
enable_data_lake      = true
enable_data_warehouse = true
enable_sagemaker      = true
```

### 2. Deploy Infrastructure

**Important**: Use the provided deployment script instead of running `terraform apply` directly. This script handles potential AWSCC provider issues and validates successful deployment.

```bash
# Initialize Terraform
terraform init

# Review the deployment plan (optional)
terraform plan

# Deploy using the wrapper script (recommended)
./terraform-apply.sh

# Or with auto-approve
./terraform-apply.sh -auto-approve
```

**Why use the script?** The AWSCC provider sometimes fails to properly track resource creation completion, even when resources are created successfully. The script validates that all resources were created and provides a clear deployment summary.

### 3. Alternative: Standard Terraform Apply

If you prefer to use standard Terraform commands:

```bash
# Deploy the infrastructure
terraform apply

# Note: You may see errors even if deployment succeeds
# Check the AWS Console to verify resources were created
```

### 3. Validate Deployment
```bash
# Run the validation script
./validate.sh
```

### 4. Configure Authorization:

#### SSO

Using the console:
- Navigate and select your newly created domain: terraform-mvp-domain
- Click Configure (right hand side, beside Configure SSO user access)
- Select IAM Identity Center
   - If you are using an AWS Organization, select either Connect to organization of IAM Identity CEnter (recommended), or Connect to an account instance of IAM Center
- Select Require assignments
- Click 'Next'
- Click 'Save'
- Select the users/groups you'd like to grant access to
   - Keep note of the groups/users selected, as if you want to regain access to the sample project created as part of this MVP project, you'll need them for section 5 to pass into the command
- Click "Add users and groups"
- Done

### 5. Grant SSO User Access (Optional: Post-Deployment)

Note, the sample project is used to test your SMUS domain configuration and project creation. The project can be deleted once it is successfully provisioned without negatively impacting the deployment. If you'd like to keep the sample project and gain access to it, run the following to grant access to your SSO user/group once SSO has been configured:

```bash
# Grant PROJECT_OWNER access to an SSO user
./grant-sso-access.sh username

# Grant PROJECT_CONTRIBUTOR access to an SSO user  
./grant-sso-access.sh user PROJECT_CONTRIBUTOR

# Grant access to an SSO group
./grant-sso-access.sh DataScientists PROJECT_CONTRIBUTOR
```

## Example Output

After successful deployment, you'll see output similar to:

```
domain_id = "dzd_abc123xyz"
domain_url = "https://dzd_abc123xyz.datazone.us-west-2.on.aws/"
project_id = "p123abc456def"
project_name = "my-analytics-project"
blueprint_count = 3
enabled_blueprints = ["DefaultDataLake", "DefaultDataWarehouse", "DefaultSageMaker"]
```

## Accessing Your MVP

1. **Visit the Domain URL**: Use the `domain_url` output to access SageMaker Unified Studio
2. **Find Your Project**: Navigate to Projects and find your project by name
3. **Explore Blueprints**: See the enabled blueprints in the Environment section

## Current Limitations

Due to Terraform AWS provider limitations, the following must be configured manually:

### ❌ Not Available in Terraform
- **Project Profiles** - Must be created via AWS Console or CLI
- **Project Memberships** - Must be managed via AWS Console or CLI

### ✅ Workarounds Available
The deployment outputs provide CLI commands for manual configuration:

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