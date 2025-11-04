#!/bin/bash

# Post-deployment script to grant SSO user access to the created project
# Usage: ./grant-sso-access.sh <sso-username-or-group>

set -e

# Check if username/group is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <sso-username-or-group> [designation]"
    echo "  designation: PROJECT_OWNER (default) or PROJECT_CONTRIBUTOR"
    echo "Example: $0 john.doe@company.com"
    echo "Example: $0 DataScientists PROJECT_CONTRIBUTOR"
    exit 1
fi

SSO_USER="$1"
DESIGNATION="${2:-PROJECT_OWNER}"

# Get domain and project info from Terraform outputs
echo "Getting deployment information..."
DOMAIN_ID=$(terraform output -raw domain_id 2>/dev/null || echo "")
PROJECT_ID=$(terraform output -raw project_id 2>/dev/null || echo "")
PROJECT_NAME=$(terraform output -raw project_name 2>/dev/null || echo "")

if [ -z "$DOMAIN_ID" ] || [ -z "$PROJECT_ID" ]; then
    echo "Error: Could not get domain_id or project_id from Terraform outputs"
    echo "Make sure you're in the correct directory and Terraform has been applied"
    exit 1
fi

echo "Domain ID: $DOMAIN_ID"
echo "Project ID: $PROJECT_ID"
echo "Project Name: $PROJECT_NAME"
echo "SSO User/Group: $SSO_USER"
echo "Designation: $DESIGNATION"
echo ""

# Grant project membership
echo "Granting $DESIGNATION access to $SSO_USER..."
aws datazone create-project-membership \
    --domain-identifier "$DOMAIN_ID" \
    --project-identifier "$PROJECT_ID" \
    --member userIdentifier="$SSO_USER" \
    --designation "$DESIGNATION" \
    --region us-west-2

if [ $? -eq 0 ]; then
    echo "✅ Successfully granted $DESIGNATION access to $SSO_USER for project '$PROJECT_NAME'"
    echo ""
    echo "Next steps:"
    echo "1. The SSO user can now access the project at: $(terraform output -raw domain_url 2>/dev/null)"
    echo "2. Navigate to Projects → $PROJECT_NAME"
    echo "3. The user can create environments using the enabled blueprints"
else
    echo "❌ Failed to grant access. Check that:"
    echo "1. SSO is properly configured for the domain"
    echo "2. The user/group '$SSO_USER' exists in your SSO provider"
    echo "3. You have the necessary permissions to manage project memberships"
fi
