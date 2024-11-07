# variables.tf
variable "vpc_id" {
  description = "VPC ID where the RDS instance will be launched"
  type        = string
}

variable "private_subnets" {
  description = "List of subnet IDs for the RDS instance"
  type        = list(string)
}

variable "db_name" {
  description = "The name of the database"
  type        = string
}

variable "db_engine" {
  description = "The database engine"
  type        = string
  default     = "mysql"
}

variable "db_engine_version" {
  description = "The version of the database engine"
  type        = string
  default     = "8.0"
}

variable "instance_class" {
  description = "The instance class for the RDS instance"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "The allocated storage for the RDS instance in GB"
  type        = number
  default     = 20
}

variable "db_username" {
  description = "The database username"
  type        = string
}

# variable "db_password" {
#   description = "The database password"
#   type        = string
#   sensitive   = true
# }

variable "multi_az" {
  description = "Whether to create a multi-AZ RDS instance"
  type        = bool
  default     = false
}

variable "publicly_accessible" {
  description = "Whether the RDS instance should be publicly accessible"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "The number of days to retain backups"
  type        = number
  default     = 7
}

variable "db_parameter_group_name" {
  description = "The DB parameter group name"
  type        = string
  default     = "default.mysql8.0"
}

variable "env" {
  description = "The environment tag for the RDS instance"
  type        = string
}
