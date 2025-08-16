# ECS Cluster Outputs
output "cluster_id" {
  description = "ID of the ECS cluster"
  value       = aws_ecs_cluster.cluster.id
}

output "cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.cluster.arn
}

output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.cluster.name
}

# Service Connect Namespace Outputs
output "service_connect_namespace_id" {
  description = "ID of the Service Connect namespace"
  value       = aws_service_discovery_http_namespace.namespace.id
}

output "service_connect_namespace_arn" {
  description = "ARN of the Service Connect namespace"
  value       = aws_service_discovery_http_namespace.namespace.arn
}

output "service_connect_namespace_name" {
  description = "Name of the Service Connect namespace"
  value       = aws_service_discovery_http_namespace.namespace.name
}

# Redis Service Outputs
output "redis_service_id" {
  description = "ID of the Redis ECS service"
  value       = aws_ecs_service.redis.id
}

output "redis_service_name" {
  description = "Name of the Redis ECS service"
  value       = aws_ecs_service.redis.name
}

output "redis_task_definition_arn" {
  description = "ARN of the Redis task definition"
  value       = aws_ecs_task_definition.redis.arn
}

output "redis_task_definition_revision" {
  description = "Revision of the Redis task definition"
  value       = aws_ecs_task_definition.redis.revision
}

output "redis_service_connect_endpoint" {
  description = "Service Connect endpoint for Redis"
  value       = "redis:6379"
}

# Flask Service Outputs
output "flask_service_id" {
  description = "ID of the Flask ECS service"
  value       = aws_ecs_service.flask_service.id
}

output "flask_service_name" {
  description = "Name of the Flask ECS service"
  value       = aws_ecs_service.flask_service.name
}

output "flask_task_definition_arn" {
  description = "ARN of the Flask task definition"
  value       = aws_ecs_task_definition.flask_task.arn
}

output "flask_task_definition_revision" {
  description = "Revision of the Flask task definition"
  value       = aws_ecs_task_definition.flask_task.revision
}

output "flask_service_connect_endpoint" {
  description = "Service Connect endpoint for Flask app"
  value       = "flask-app:${var.container_port}"
}

# Security Group Outputs
output "redis_security_group_id" {
  description = "ID of the Redis security group"
  value       = aws_security_group.redis.id
}

output "flask_security_group_id" {
  description = "ID of the Flask security group"
  value       = aws_security_group.flask.id
}

# IAM Role Outputs
output "ecs_execution_role_arn" {
  description = "ARN of the ECS execution role"
  value       = aws_iam_role.ecs_execution_role.arn
}

output "ecs_task_role_arn" {
  description = "ARN of the ECS task role"
  value       = aws_iam_role.ecs_task_role.arn
}

# CloudWatch Log Group Outputs
output "redis_log_group_name" {
  description = "Name of the Redis CloudWatch log group"
  value       = aws_cloudwatch_log_group.redis_logs.name
}

output "redis_log_group_arn" {
  description = "ARN of the Redis CloudWatch log group"
  value       = aws_cloudwatch_log_group.redis_logs.arn
}

output "flask_log_group_name" {
  description = "Name of the Flask CloudWatch log group"
  value       = aws_cloudwatch_log_group.flask_logs.name
}

output "flask_log_group_arn" {
  description = "ARN of the Flask CloudWatch log group"
  value       = aws_cloudwatch_log_group.flask_logs.arn
}

# Auto Scaling Outputs
output "auto_scaling_target_resource_id" {
  description = "Resource ID of the auto scaling target"
  value       = aws_appautoscaling_target.ecs_target.resource_id
}

output "cpu_scaling_policy_arn" {
  description = "ARN of the CPU-based auto scaling policy"
  value       = aws_appautoscaling_policy.ecs_policy_cpu.arn
}

output "memory_scaling_policy_arn" {
  description = "ARN of the memory-based auto scaling policy"
  value       = aws_appautoscaling_policy.ecs_policy_memory.arn
}

# Service Discovery Information
output "service_discovery_info" {
  description = "Service discovery information for connecting to services"
  value = {
    redis_endpoint    = "redis:6379"
    flask_endpoint    = "flask-app:${var.container_port}"
    namespace         = aws_service_discovery_http_namespace.namespace.name
    connection_method = "Use short names within the same namespace"
  }
}

# Deployment Information
output "deployment_info" {
  description = "Information about the deployed services"
  value = {
    cluster_name              = aws_ecs_cluster.cluster.name
    redis_service_name        = aws_ecs_service.redis.name
    flask_service_name        = aws_ecs_service.flask_service.name
    redis_desired_count       = aws_ecs_service.redis.desired_count
    flask_desired_count       = aws_ecs_service.flask_service.desired_count
    service_connect_enabled   = true
    container_insights_enabled = true
  }
}

# Connection Examples
output "connection_examples" {
  description = "Examples of how to connect to services"
  value = {
    redis_connection_from_flask = {
      host = "redis"
      port = "6379"
      example_code = "redis.Redis(host='redis', port=6379)"
    }
    flask_connection_from_other_services = {
      host = "flask-app"
      port = var.container_port
      example_url = "http://flask-app:${var.container_port}/health"
    }
  }
}

# Monitoring URLs (conditional - only if you have ALB)
output "monitoring_endpoints" {
  description = "Monitoring and health check endpoints"
  value = {
    cloudwatch_logs = {
      redis_logs = "https://console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.id}#logsV2:log-groups/log-group/${urlencode(aws_cloudwatch_log_group.redis_logs.name)}"
      flask_logs = "https://console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.id}#logsV2:log-groups/log-group/${urlencode(aws_cloudwatch_log_group.flask_logs.name)}"
    }
    ecs_console = {
      cluster = "https://console.aws.amazon.com/ecs/home?region=${data.aws_region.current.id}#/clusters/${aws_ecs_cluster.cluster.name}"
      redis_service = "https://console.aws.amazon.com/ecs/home?region=${data.aws_region.current.id}#/clusters/${aws_ecs_cluster.cluster.name}/services/${aws_ecs_service.redis.name}"
      flask_service = "https://console.aws.amazon.com/ecs/home?region=${data.aws_region.current.id}#/clusters/${aws_ecs_cluster.cluster.name}/services/${aws_ecs_service.flask_service.name}"
    }
  }
}

# Resource ARNs for cross-module references
output "resource_arns" {
  description = "ARNs of created resources for cross-module references"
  value = {
    cluster_arn                = aws_ecs_cluster.cluster.arn
    namespace_arn             = aws_service_discovery_http_namespace.namespace.arn
    redis_service_arn         = aws_ecs_service.redis.id
    flask_service_arn         = aws_ecs_service.flask_service.id
    redis_task_definition_arn = aws_ecs_task_definition.redis.arn
    flask_task_definition_arn = aws_ecs_task_definition.flask_task.arn
    execution_role_arn        = aws_iam_role.ecs_execution_role.arn
    task_role_arn            = aws_iam_role.ecs_task_role.arn
  }
}