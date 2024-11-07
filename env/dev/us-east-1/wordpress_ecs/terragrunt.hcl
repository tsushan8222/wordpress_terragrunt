terraform {
  source = "${get_parent_terragrunt_dir()}/../_modules/ecs"
}

include "root" {
  path = find_in_parent_folders()
}

dependencies {
  paths = ["${get_parent_terragrunt_dir()}/${local.global_environment_vars.locals.environment}/${local.regional_vars.locals.aws_region}/wordpress_vpc",
            "${get_parent_terragrunt_dir()}/${local.global_environment_vars.locals.environment}/${local.regional_vars.locals.aws_region}/wordpress_ecr"
            ]
}

dependency "wordpress_vpc" {
  config_path = "${get_parent_terragrunt_dir()}/${local.global_environment_vars.locals.environment}/${local.regional_vars.locals.aws_region}/wordpress_vpc"
}

dependency "wordpress_ecr" {
  config_path = "${get_parent_terragrunt_dir()}/${local.global_environment_vars.locals.environment}/${local.regional_vars.locals.aws_region}/wordpress_ecr"
}

locals {
  global_environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  #global_secret_vars      = yamldecode(sops_decrypt_file(find_in_parent_folders("global_secret.${local.global_environment_vars.locals.environment}.yaml")))
  regional_vars           = read_terragrunt_config(find_in_parent_folders("region.hcl"))
}

inputs = {
  env             = local.global_environment_vars.locals.environment  
  cluster_name    = "wordpress-ecs-cluster"
  image_arn       = "${dependency.wordpress_ecr.outputs.ecr_repository_uri}:latest"
  log_group_name  = "/aws/ecs/wordpress-ecs"
  region          = local.regional_vars.locals.aws_region
  vpc_id          = dependency.wordpress_vpc.outputs.vpc_id
  public_subnets  = dependency.wordpress_vpc.outputs.public_subnet_ids
  private_subnets = dependency.wordpress_vpc.outputs.private_subnet_ids
  secret     = "arn:aws:secretsmanager:us-east-1:156041424049:secret:wordpress-A1Ctec"

}
