## Mandatory CI test — mock providers, no real AWS resources.
## Validates the full quick-setup module graph without needing credentials.

mock_provider "aws" {}
mock_provider "awscc" {}
mock_provider "random" {}
mock_provider "time" {}
mock_provider "null" {}

run "mandatory_plan_basic" {
  command = plan
  module {
    source = "./examples/quick-setup"
  }

  variables {
    vpc_id     = "vpc-abc123"
    subnet_ids = ["subnet-abc123"]
  }
}

run "mandatory_apply_basic" {
  command = apply
  module {
    source = "./examples/quick-setup"
  }

  variables {
    vpc_id     = "vpc-abc123"
    subnet_ids = ["subnet-abc123"]
  }
}
