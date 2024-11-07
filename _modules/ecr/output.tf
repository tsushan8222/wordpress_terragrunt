output "ecr_repository_name" {
  description = "The name of the ECR repository"
  value       = module.ecr.repository_name
}

output "ecr_repository_arn" {
  description = "The ARN of the ECR repository"
  value       = module.ecr.repository_arn
}

output "ecr_repository_uri" {
  description = "The URI of the ECR repository, used for Docker login and push"
  value       = module.ecr.repository_url
}

