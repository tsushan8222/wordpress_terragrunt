module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.15.0"

  name = "${var.env}-${var.vpc_name}"
  cidr = var.cidr_block

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway   = true

  flow_log_file_format = "parquet"

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}