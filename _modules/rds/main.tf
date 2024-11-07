# main.tf

module "db" {
  source = "terraform-aws-modules/rds/aws"

  # Basic RDS Configuration
  db_subnet_group_name   = "${var.db_name}-subnet-group"
  vpc_id                 = var.vpc_id
  subnet_ids             = var.private_subnets
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
  db_parameter_group_name = var.db_parameter_group_name
  skip_final_snapshot    = true

  # VPC Security Groups and Ingress
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  # Tags
  tags = {
    Environment = var.env
  }

  # Enable automatic minor version upgrade
  auto_minor_version_upgrade = true
}

# Outputs
output "rds_endpoint" {
  value = module.db.endpoint
}

output "rds_instance_id" {
  value = module.db.id
}
