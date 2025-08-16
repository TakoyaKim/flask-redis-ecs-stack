output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "load_balancer_dns" {
  description = "DNS name of the load balancer"
  value       = module.alb.dns_name
}

output "load_balancer_url" {
  description = "URL of the load balancer"
  value       = "http://${module.alb.dns_name}"
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs.cluster_name
}

output "flask_service_name" {
  description = "Name of the Flask ECS service"
  value       = module.ecs.flask_service_name
}

output "redis_service_name" {
  description = "Name of the Redis ECS service"
  value       = module.ecs.redis_service_name
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = module.my_ecr_repo.repository_url
}

output "ecr_repository_arn" {
  description = "ECR repository ARN"
  value       = module.my_ecr_repo.repository_arn
}