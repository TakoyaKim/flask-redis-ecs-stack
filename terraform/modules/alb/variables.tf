variable "alb_name" {
  description = "ALB name"
  type        = string
}

variable "is_internal" {
  description = "Whether the ALB is internal or internet-facing"
  type        = bool
  default     = false
}

variable "lb_type" {
  description = "Load balancer type"
  type        = string
  default     = "application"
}

variable "sg" {
  description = "security group"
  type        = string
}

variable "subnets" {
  description = "subnets associated"
  type        = list(string)
}

variable "deletion_protection" {
  description = "enable deletion protection"
  type        = bool
  default     = false
}

variable "target_port" {
  description = "Port for the target group"
  type        = number
  default     = 80
}

variable "target_protocol" {
  description = "Protocol for the target group"
  type        = string
  default     = "HTTP"
}

variable "vpc_id" {
  description = "VPC ID for the target group"
  type        = string
}

variable "health_check_path" {
  description = "Health check path for the target group"
  type        = string
  default     = "/"
}