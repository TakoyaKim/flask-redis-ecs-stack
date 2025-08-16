variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "doex10"
}

variable "environment" {
  description = "Environment type"
  type        = string
  default     = "development"
}

# ECS Configuration
variable "container_image" {
  description = "Docker image for the container"
  type        = string
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
  default     = 5000
}

variable "ecs_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  type        = number
  default     = 256
}

variable "ecs_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  type        = number
  default     = 512
}

variable "ecs_desired_count" {
  description = "Number of instances of the task definition to place and keep running"
  type        = number
  default     = 2
}

# Auto Scaling
variable "auto_scaling_min_capacity" {
  description = "Minimum number of tasks to run"
  type        = number
  default     = 2
}

variable "auto_scaling_max_capacity" {
  description = "Maximum number of tasks to run"
  type        = number
  default     = 10
}

variable "cpu_target_value" {
  description = "Target CPU utilization for auto scaling"
  type        = number
  default     = 70
}

variable "memory_target_value" {
  description = "Target memory utilization for auto scaling"
  type        = number
  default     = 80
}

variable "scale_in_cooldown" {
  description = "Scale in cooldown period in seconds"
  type        = number
  default     = 300
}

variable "scale_out_cooldown" {
  description = "Scale out cooldown period in seconds"
  type        = number
  default     = 300
}

# Application Configuration
variable "database_url" {
  description = "Database connection URL"
  type        = string
  sensitive   = true
}

variable "health_check_path" {
  description = "Health check path for the application"
  type        = string
  default     = "/health"
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 14
}

variable "environment_variables" {
  type    = list(map(string))
  default = []
}