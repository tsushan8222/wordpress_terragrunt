module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.15.0"

  name = "${var.env}-${var.vpc_name}"
  cidr = "10.0.0.0/16"

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.private_subnets

  enable_nat_gateway = var.enable_nat_gateway
  enable_vpn_gateway = false
  single_nat_gateway   = false

  flow_log_file_format = "parquet"

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}