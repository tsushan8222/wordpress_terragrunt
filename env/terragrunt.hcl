#export AWS_PROFILE="dev"
#export TERRAGRUNT_IAM_ROLE="arn:aws:iam::ACCOUNT_ID:role/ROLE_NAME"
#terraform_version_constraint  = ">= 0.14.4"
#terragrunt_version_constraint = ">= 0.27"


dependency "account" {
  config_path = find_in_parent_folders("account.hcl")
}

locals {
  # Automatically load account-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract the variables we need for easy access
  account_name         = local.account_vars.locals.account_name
  account_id           = local.account_vars.locals.aws_account_id
  aws_region           = local.region_vars.locals.aws_region
  tf_state_bucket_name = "${get_env("TG_BUCKET_PREFIX", "")}wordpress-terraform-state-${local.account_name}-${local.aws_region}"
}

# Generate an AWS provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "${local.account_name}"
}
EOF
}

# Configure Terragrunt to automatically store tfstate files in an S3 bucket
remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = "${local.tf_state_bucket_name}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    profile        = "${local.account_name}"
    dynamodb_table = "terraform-locks"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}


# ---------------------------------------------------------------------------------------------------------------------
# GLOBAL PARAMETERS
# These variables apply to all configurations in this subfolder. These are automatically merged into the child
# `terragrunt.hcl` config via the include block.
# ---------------------------------------------------------------------------------------------------------------------

# Configure root level variables that all resources can inherit. This is especially helpful with multi-account configs
# where terraform_remote_state data sources are placed directly into the modules.
inputs = merge(
  local.account_vars.locals,
  local.region_vars.locals,
  local.environment_vars.locals,
  { "tf_state_bucket_name" = local.tf_state_bucket_name }
)
