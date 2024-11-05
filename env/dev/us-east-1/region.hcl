# Set common variables for the region. This is automatically pulled in in the root terragrunt.hcl configuration to
# configure the remote state bucket and pass forward to the child modules as inputs.

# Set common variables for the region. This is automatically pulled in in the root terragrunt.hcl configuration to
# configure the remote state bucket and pass forward to the child modules as inputs.
locals {
  aws_region    = "us-east-1"
  accounts_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Extract out common variables for reuse
  account_name    = local.accounts_vars.locals.account_name
  aws_account_id  = local.accounts_vars.locals.aws_account_id
  #file_name       = "common_regional_vars.hcl.json"
  #common_var_file = "${path_relative_to_include()}/${run_cmd("./get_cfn_exports.sh", local.account_name, local.aws_region, local.file_name, local.aws_account_id)}"
}

generate "regional_vars" {
  path      = "common_regional_vars.hcl.json"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
{
  "locals" : { 
    "common_vars" : [] 
  } 
}
EOF
}

# include "root" {
#   path = find_in_parent_folders()
# }


