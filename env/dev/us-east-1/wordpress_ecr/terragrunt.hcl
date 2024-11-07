terraform {
  source = "${get_parent_terragrunt_dir()}/../_modules/ecr"
}

include "root" {
  path = find_in_parent_folders()
}


locals {
  global_environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  #global_secret_vars      = yamldecode(sops_decrypt_file(find_in_parent_folders("global_secret.${local.global_environment_vars.locals.environment}.yaml")))
  regional_vars           = read_terragrunt_config(find_in_parent_folders("region.hcl"))
}

inputs = {
  env             = local.global_environment_vars.locals.environment  
  repository_name        = "wordpress"

}
