## NOTE: This is the minimum mandatory test
# run at least one test using the ./examples directory as your module source
# create additional *.tftest.hcl for your own unit / integration tests
# use tests/*.auto.tfvars to add non-default variables
run "mandatory_plan_domain" {
  command = plan
  module {
    source = "./"
  }

  variables {
    vpc_id         = "vpc-abc123"
    subnet_ids     = ["subnet-abc123"]
    s3_bucket_name = "test-bucket-domain"
  }
}

run "mandatory_apply_domain" {
  command = apply
  module {
    source = "./"
  }

  variables {
    vpc_id         = "vpc-abc123"
    subnet_ids     = ["subnet-abc123"]
    s3_bucket_name = "test-bucket-domain"
  }
}