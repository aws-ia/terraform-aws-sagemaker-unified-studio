# Multi-Account SageMaker Unified Studio Domain Example

This example demonstrates how to create a SageMaker Unified Studio domain with organization-wide resource sharing using Terraform. It provides the same functionality as the CloudFormation templates `cloudformation/domain/create_domain.yaml`, `fetch_accounts.yml`, and `create_resource_share.yaml` combined.

## What This Example Creates

- **SageMaker Unified Studio Domain**: A domain configured for unified data, analytics, and AI workloads
- **Organization Integration**: Automatic discovery of AWS Organization accounts
- **Resource Sharing**: AWS RAM resource shares for cross-account domain access
- **IAM Roles**: All required IAM roles with proper permissions
- **SSO Integration**: AWS IAM Identity Center integration (optional)

## Prerequisites

1. **AWS Organizations**: Your AWS account must be part of an AWS Organization
2. **Organization Permissions**: The account deploying this must have permissions to:
   - List organization accounts (`organizations:ListAccounts`)
   - Create resource shares (`ram:CreateResourceShare`)
   - Associate resources and principals with shares
3. **AWS CLI configured** with appropriate credentials
4. **Terraform >= 1.5** installed
5. **AWS Provider >= 5.0** (automatically downloaded)

## Quick Start

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd terraform/examples/multi-account-domain
   ```

2. **Configure your deployment**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your organization ID and preferences
   ```

3. **Initialize Terraform**:
   ```bash
   terraform init
   ```

4. **Review the plan**:
   ```bash
   terraform plan
   ```

5. **Apply the configuration**:
   ```bash
   terraform apply
   ```

6. **Access your domain**:
   - Use the `domain_url` output to access the SageMaker Unified Studio portal
   - The domain will be accessible from all accounts in your organization

## Configuration Options

### Required Configuration

```hcl
# Your AWS Organizations ID (required)
organization_id = "o-1234567890"

# Domain name (must be unique)
domain_name = "my-enterprise-domain"
```

### Account Sharing Options

```hcl
# Exclude management account from sharing (recommended)
exclude_management_account = true

# Share with specific accounts only (overrides organization discovery)
specific_account_ids = ["123456789012", "123456789013"]

# Allow sharing outside your organization
allow_external_principals = false

# Automatically accept resource shares within organization
auto_accept_shares = true
```

### Advanced Configuration

```hcl
# Disable resource sharing (domain only accessible from current account)
enable_resource_sharing = false

# Include current account in resource sharing
exclude_current_account = false

# Disable SSO integration
enable_sso = false
```

## Comparison with CloudFormation

This Terraform example provides the same functionality as the CloudFormation templates with these advantages:

| Feature | CloudFormation | Terraform |
|---------|---------------|-----------|
| **Account Discovery** | Lambda function | Native data sources |
| **Resource Sharing** | ForEach loop | for_each with validation |
| **Organization Integration** | Manual parameter | Automatic discovery |
| **Error Handling** | Lambda try/catch | Built-in validation |
| **State Management** | Stack-based | Granular state tracking |
| **Modularity** | Nested stacks | Reusable modules |

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    AWS Organization                              │
│                                                                 │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │   Account A     │  │   Account B     │  │   Account C     │ │
│  │                 │  │                 │  │                 │ │
│  │ ┌─────────────┐ │  │ ┌─────────────┐ │  │ ┌─────────────┐ │ │
│  │ │   Domain    │ │  │ │   Domain    │ │  │ │   Domain    │ │ │
│  │ │   Access    │ │  │ │   Access    │ │  │ │   Access    │ │ │
│  │ └─────────────┘ │  │ └─────────────┘ │  │ └─────────────┘ │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
│           │                     │                     │        │
│           └─────────────────────┼─────────────────────┘        │
│                                 │                              │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              Management Account                         │   │
│  │                                                         │   │
│  │  ┌─────────────────────────────────────────────────┐    │   │
│  │  │        SageMaker Unified Studio Domain          │    │   │
│  │  │                                                 │    │   │
│  │  │  ┌─────────────┐  ┌─────────────────────────┐   │    │   │
│  │  │  │ DataZone    │  │    AWS RAM Resource     │   │    │   │
│  │  │  │ Domain      │  │    Share                │   │    │   │
│  │  │  └─────────────┘  └─────────────────────────┘   │    │   │
│  │  └─────────────────────────────────────────────────┘    │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

## Outputs

After successful deployment, you'll receive:

```bash
# Domain information
domain_id = "dzd_1234567890abcdef"
domain_url = "https://dzd_1234567890abcdef.datazone.us-east-1.amazonaws.com"
domain_status = "AVAILABLE"

# Organization information
organization_id = "o-1234567890"
total_accounts_found = 5
accounts_for_sharing_count = 4

# Resource sharing information
resource_sharing_enabled = true
resource_share_name = "DataZone-my-domain-dzd_1234567890abcdef"
resource_share_status = "ACTIVE"

# Next steps guidance
next_steps = {
  access_url = "Visit https://... to access your domain"
  shared_accounts = "Domain is shared with 4 accounts in your organization"
  sso_setup = "SSO is enabled - configure users in AWS IAM Identity Center"
}
```

## Multi-Account Access

Once deployed, users in shared accounts can:

1. **Access the domain** using the same portal URL
2. **Create projects** within the shared domain
3. **Collaborate** across account boundaries
4. **Share data assets** between accounts
5. **Use shared blueprints** and environments

## Troubleshooting

### Common Issues

1. **Organization Access Denied**: Ensure the deploying account has `organizations:ListAccounts` permission
2. **Resource Share Failed**: Check that accounts are part of the same organization
3. **Domain Not Accessible**: Verify resource shares are accepted in target accounts
4. **SSO Issues**: Ensure AWS IAM Identity Center is configured

### Validation Commands

```bash
# Check organization accounts
aws organizations list-accounts

# Check resource shares
aws ram get-resource-shares --resource-owner SELF

# Check domain status
aws datazone get-domain --identifier <domain-id>
```

## Cleanup

To remove all resources:

```bash
terraform destroy
```

**Warning**: This will permanently delete your domain and all associated resources across all accounts.

## Next Steps

After creating your multi-account domain:

1. **Configure Users**: Set up users and groups in AWS IAM Identity Center
2. **Enable Blueprints**: Use additional modules to enable specific environment blueprints
3. **Create Projects**: Set up projects for your teams across different accounts
4. **Set up Governance**: Configure data governance policies and access controls

## Related Examples

- [Basic Domain](../basic-domain/) - Single-account domain setup
- [Analytics Focused](../analytics-focused/) - Analytics workload optimization
- [AI/ML Focused](../ai-ml-focused/) - Machine learning platform setup
