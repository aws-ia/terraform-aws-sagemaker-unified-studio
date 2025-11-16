package test

import (
	"testing"
	"fmt"
	"strings"
	"time"
	"math/rand"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/stretchr/testify/assert"
)

// TestBasicDomainCreation tests the basic domain creation functionality
func TestBasicDomainCreation(t *testing.T) {
	t.Parallel()

	// Generate a random domain name to avoid conflicts
	domainName := fmt.Sprintf("test-domain-%s", randomString(8))
	awsRegion := "us-east-1"

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// Path to the Terraform code that will be tested
		TerraformDir: "../../examples/basic-domain",

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"domain_name":        domainName,
			"aws_region":         awsRegion,
			"environment":        "test",
			"owner":             "terratest",
			"domain_description": "Test domain created by Terratest",
		},

		// Environment variables to set when running Terraform
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	})

	// Clean up resources with "terraform destroy" at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Run "terraform init" and "terraform apply"
	terraform.InitAndApply(t, terraformOptions)

	// Validate the outputs
	validateDomainOutputs(t, terraformOptions, domainName, awsRegion)
	
	// Validate IAM roles were created
	validateIAMRoles(t, terraformOptions, domainName)
	
	// Validate domain is accessible (basic check)
	validateDomainAccessibility(t, terraformOptions)
}

// validateDomainOutputs checks that all expected outputs are present and valid
func validateDomainOutputs(t *testing.T, terraformOptions *terraform.Options, expectedDomainName, expectedRegion string) {
	// Check domain_id output
	domainID := terraform.Output(t, terraformOptions, "domain_id")
	assert.NotEmpty(t, domainID, "Domain ID should not be empty")
	assert.True(t, strings.HasPrefix(domainID, "d-"), "Domain ID should start with 'd-'")

	// Check domain_arn output
	domainARN := terraform.Output(t, terraformOptions, "domain_arn")
	assert.NotEmpty(t, domainARN, "Domain ARN should not be empty")
	assert.Contains(t, domainARN, "datazone", "Domain ARN should contain 'datazone'")
	assert.Contains(t, domainARN, expectedRegion, "Domain ARN should contain the expected region")

	// Check domain_name output
	domainName := terraform.Output(t, terraformOptions, "domain_name")
	assert.Equal(t, expectedDomainName, domainName, "Domain name should match expected value")

	// Check domain_url output
	domainURL := terraform.Output(t, terraformOptions, "domain_url")
	assert.NotEmpty(t, domainURL, "Domain URL should not be empty")
	assert.True(t, strings.HasPrefix(domainURL, "https://"), "Domain URL should start with https://")
	assert.Contains(t, domainURL, "datazone", "Domain URL should contain 'datazone'")

	// Check root_domain_unit_id output
	rootDomainUnitID := terraform.Output(t, terraformOptions, "root_domain_unit_id")
	assert.NotEmpty(t, rootDomainUnitID, "Root domain unit ID should not be empty")

	// Check domain_status output
	domainStatus := terraform.Output(t, terraformOptions, "domain_status")
	assert.Equal(t, "AVAILABLE", domainStatus, "Domain status should be AVAILABLE")

	// Check account_id and region outputs
	accountID := terraform.Output(t, terraformOptions, "account_id")
	assert.NotEmpty(t, accountID, "Account ID should not be empty")
	assert.Len(t, accountID, 12, "Account ID should be 12 digits")

	region := terraform.Output(t, terraformOptions, "region")
	assert.Equal(t, expectedRegion, region, "Region should match expected value")
}

// validateIAMRoles checks that the expected IAM roles were created
func validateIAMRoles(t *testing.T, terraformOptions *terraform.Options, domainName string) {
	// Get the list of created IAM roles
	createdRolesOutput := terraform.Output(t, terraformOptions, "created_iam_roles")
	assert.NotEmpty(t, createdRolesOutput, "Created IAM roles list should not be empty")

	// Expected role names
	expectedRoles := []string{
		fmt.Sprintf("%s-domain-execution-role", domainName),
		fmt.Sprintf("%s-service-role", domainName),
		fmt.Sprintf("%s-sagemaker-manage-access-role", domainName),
		fmt.Sprintf("%s-sagemaker-provisioning-role", domainName),
	}

	// Parse the output (it's a JSON array as string)
	for _, expectedRole := range expectedRoles {
		assert.Contains(t, createdRolesOutput, expectedRole, 
			fmt.Sprintf("Created roles should contain %s", expectedRole))
	}

	// Validate that the roles actually exist in AWS
	awsRegion := terraform.Output(t, terraformOptions, "region")
	for _, roleName := range expectedRoles {
		role := aws.GetIamRole(t, roleName)
		assert.NotNil(t, role, fmt.Sprintf("IAM role %s should exist in AWS", roleName))
		assert.Equal(t, roleName, *role.RoleName, "Role name should match")
	}
}

// validateDomainAccessibility performs basic accessibility checks
func validateDomainAccessibility(t *testing.T, terraformOptions *terraform.Options) {
	domainURL := terraform.Output(t, terraformOptions, "domain_url")
	
	// Basic URL format validation
	assert.True(t, strings.HasPrefix(domainURL, "https://"), "Domain URL should use HTTPS")
	assert.True(t, strings.Contains(domainURL, ".amazonaws.com"), "Domain URL should be on amazonaws.com")
	
	// Note: We don't test actual HTTP connectivity here as it requires authentication
	// and the domain might take time to be fully available
	t.Logf("Domain URL is accessible at: %s", domainURL)
}

// randomString generates a random string of specified length
func randomString(length int) string {
	const charset = "abcdefghijklmnopqrstuvwxyz0123456789"
	seededRand := rand.New(rand.NewSource(time.Now().UnixNano()))
	
	b := make([]byte, length)
	for i := range b {
		b[i] = charset[seededRand.Intn(len(charset))]
	}
	return string(b)
}

// TestDomainWithCustomConfiguration tests domain creation with custom configuration
func TestDomainWithCustomConfiguration(t *testing.T) {
	t.Parallel()

	domainName := fmt.Sprintf("custom-test-%s", randomString(6))
	
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../examples/basic-domain",
		Vars: map[string]interface{}{
			"domain_name":        domainName,
			"aws_region":         "us-west-2",
			"environment":        "staging",
			"owner":             "test-team",
			"domain_description": "Custom test domain with specific configuration",
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": "us-west-2",
		},
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Validate custom configuration
	domainNameOutput := terraform.Output(t, terraformOptions, "domain_name")
	assert.Equal(t, domainName, domainNameOutput)
	
	regionOutput := terraform.Output(t, terraformOptions, "region")
	assert.Equal(t, "us-west-2", regionOutput)
}
