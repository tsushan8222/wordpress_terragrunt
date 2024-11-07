variable "env" {
  type        = string
  default     = "dev"
  description = "Env Name"
}

variable "vpc_name" {
  description = "Name of the VPC"
  default = "wordpress"
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "azs" {
  type        = list(string)
  description = "VPC AZs"
}

variable "private_subnets" {
  type        = list(string)
  description = "VPC private subnets"
}

variable "public_subnets" {
  type        = list(string)
  description = "VPC public subnets"
}

variable "enable_nat_gateway" {
  type        = bool
  default     = true
  description = "VPC enable nat gateway "
}

