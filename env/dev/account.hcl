# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.
locals {
  account_name   = "default"
  aws_account_id = "156041424049"
  aws_profile    = "dev"
}


