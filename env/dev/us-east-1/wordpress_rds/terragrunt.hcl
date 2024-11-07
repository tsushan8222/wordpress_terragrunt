terraform {
  source = "${get_parent_terragrunt_dir()}/../_modules/rds"
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
  region          = local.regional_vars.locals.aws_region
  vpc_id          = dependency.wordpress_vpc.outputs.vpc_id
  private_subnets = dependency.wordpress_vpc.outputs.private_subnet_ids
  db_name                 = "wordpress"
  db_engine               = "mysql"
  db_engine_version       = "8.0"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  db_username             = "admin"
  multi_az                = false
  publicly_accessible     = false
  backup_retention_period = 7
  allowed_cidr_blocks     = ["0.0.0.0/0"]

}
