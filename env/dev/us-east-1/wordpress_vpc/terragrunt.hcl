terraform {
  source = "${get_parent_terragrunt_dir()}/../_modules/vpc"
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
  vpc_name        = "wordpress"
  cidr_block      = "10.0.0.0/16"
  azs             = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.0.10.0/24", "10.0.11.0/24"]
  private_subnets = ["10.0.20.0/24", "10.0.21.0/24"]
  enable_nat_gateway = true
}
