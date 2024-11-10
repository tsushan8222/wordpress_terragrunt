# main.tf

module "db" {
  source = "terraform-aws-modules/rds/aws"
  version = "6.10.0"

  identifier = "wordpress"

  # Basic RDS Configuration
  # db_subnet_group_name   = aws_security_group.rds_sg.name
  subnet_ids             = var.private_subnets
  create_db_subnet_group = true
#  subnet_ids             = ["subnet-0b42927bc25c06550", "subnet-0febd79ab92172d5c"]
  db_name                = var.db_name
  engine                 = var.db_engine
  engine_version         = var.db_engine_version
  instance_class         = var.instance_class
  allocated_storage      = var.allocated_storage
  username               = var.db_username
#  password               = var.db_password
  multi_az               = var.multi_az
  storage_encrypted      = true
  publicly_accessible    = var.publicly_accessible
  backup_retention_period = var.backup_retention_period
  # db_parameter_group_name = var.db_parameter_group_name
  skip_final_snapshot    = true
  # name_prefix = local.sanitized_name_prefix
  major_engine_version = var.major_engine_version

  family = var.family  

  # VPC Security Groups and Ingress
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  # Tags
  tags = {
    Environment = var.env
  }

  # Enable automatic minor version upgrade
  auto_minor_version_upgrade = true
}

# locals {
#   sanitized_name_prefix = replace(lower(var.name_prefix), "/[^a-z0-9-]/", "")
# }

