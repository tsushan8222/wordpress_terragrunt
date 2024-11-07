variable "repository_name" {
  description = "Name of the VPC"
  default = "wordpress"
  type        = string
}

variable "env" {
  type        = string
  default     = "dev"
  description = "Env Name"
}