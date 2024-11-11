variable "env" {
  type        = string
  default     = "dev"
  description = "Env Name"
}

variable "vpc_id" {
  type        = string
  description = "VPC id"
}

variable "ssl_certificate_arn" {
  type        = string
  description = "ssl_certificate_arn"
}

variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
  default     = "ecs-integrated"
}

variable "image_arn" {
  description = "Name of the ECS cluster"
  type        = string
  default     = "ecs-integrated"
}

variable "log_group_name" {
  description = "CloudWatch log group name for ECS"
  type        = string
  default     = "/aws/ecs/aws-ec2"
}

variable "namespace" {
  description = "Namespace for Service Connect configuration"
  type        = string
  default     = "example"
}

variable "region" {
  description = "The AWS region where resources are created"
  type        = string
  default     = "eu-west-1"
}

variable "fargate_capacity_providers" {
  description = "Configuration for Fargate capacity providers"
  type        = map(object({
    default_capacity_provider_strategy = object({
      weight = number
    })
  }))
  default = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    },
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }
}

# variable "services" {
#   description = "Service configurations for ECS"
#   type = map(object({
#     cpu                     = number
#     memory                  = number
#     container_definitions   = map(any) // Define as a map of objects to support multiple containers
#     service_connect_configuration = object({
#       namespace = string
#       service = object({
#         client_alias = object({
#           port     = number
#           dns_name = string
#         })
#         port_name      = string
#         discovery_name = string
#       })
#     })
#     load_balancer = object({
#       service = object({
#         target_group_arn = string
#         container_name   = string
#         container_port   = number
#       })
#     })
#     subnet_ids           = list(string)
#     security_group_rules = map(any)
#   }))
# }

variable "public_subnets" {
  description = "Public Subnet IDs for ECS tasks"
  type        = list(string)
}

variable "private_subnets" {
  description = "Public Subnet IDs for ECS tasks"
  type        = list(string)
}

variable "secret" {
  description = "Secret manager arn"
  type        = string
}

# variable "security_group_rules" {
#   description = "Security group rules for ECS tasks"
#   type        = map(any) // Allows a flexible structure for security group rules
# }

variable "tags" {
  description = "Tags for the resources"
  type        = map(string)
  default     = {
    Environment = "Development"
    Project     = "Example"
  }
}
