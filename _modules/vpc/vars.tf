variable "env" {
  type        = string
  default     = "dev"
  description = "VPC AZs"
}

variable "vpc_name" {
  description = "Name of the VPC"
  default = "wordpress"
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  default = "10.0.0.0/16"
  type        = string
}

variable "azs" {
  type        = list(string)
#  default     = ["us-east-1a", "us-east-1b"]
  description = "VPC AZs"
}

variable "private_subnets" {
  type        = list(string)
#  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  description = "VPC private subnets"
}

variable "public_subnets" {
  type        = list(string)
#  default     = ["10.0.101.0/24", "10.0.102.0/24"]
  description = "VPC public subnets"
}

variable "enable_nat_gateway" {
  type        = bool
  default     = false
  description = "VPC enable nat gateway "
}

