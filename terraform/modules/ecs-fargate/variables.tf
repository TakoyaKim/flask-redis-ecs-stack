# modules/ecs/variables.tf

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "service_name" {
  description = "Name of the ECS service"
  type        = string
}

variable "task_family" {
  description = "Task definition family name"
  type        = string
}

variable "container_name" {
  description = "Name of the container"
  type        = string
}

variable "container_image" {
  description = "Docker image URL"
  type        = string
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
  default     = 5000
}

variable "cpu" {
  description = "Number of cpu units used by the task"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Amount (in MiB) of memory used by the task"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Number of instances of the task definition"
  type        = number
  default     = 2
}

# Networking
variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group ID of the ALB"
  type        = string
}

variable "assign_public_ip" {
  description = "Whether to assign public IP"
  type        = bool
  default     = false
}

variable "target_group_arn" {
  description = "ARN of the target group"
  type        = string
}

# Auto Scaling
variable "auto_scaling_min_capacity" {
  description = "Minimum capacity for auto scaling"
  type        = number
  default     = 1
}

variable "auto_scaling_max_capacity" {
  description = "Maximum capacity for auto scaling"
  type        = number
  default     = 10
}

variable "cpu_target_value" {
  description = "Target CPU utilization for scaling"
  type        = number
  default     = 70
}

variable "memory_target_value" {
  description = "Target memory utilization for scaling"
  type        = number
  default     = 80
}

variable "scale_in_cooldown" {
  description = "Scale in cooldown period"
  type        = number
  default     = 300
}

variable "scale_out_cooldown" {
  description = "Scale out cooldown period"
  type        = number
  default     = 300
}

# Application Configuration
variable "environment_variables" {
  description = "Environment variables for the container"
  type        = list(map(string))
  default     = []
}

variable "secrets" {
  description = "Secrets for the container"
  type        = list(map(string))
  default     = []
}

variable "health_check_command" {
  description = "Health check command"
  type        = string
  default     = "curl -f http://localhost:5000/health || exit 1"
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "deployment_strategy" {
  description = "Deployment strategy for the ECS service"
  type        = string
  default     = "ROLLING"
}

variable "bake_time" {
  description = "Bake time for the deployment in minutes"
  type        = number
  default     = 5
}
