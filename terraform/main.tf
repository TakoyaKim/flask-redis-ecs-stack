module "vpc" {
  source          = "./modules/vpc"
  vpc_name        = "DOEx10"
  vpc_cidr        = "10.0.0.0/16"
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  azs             = ["us-east-2a", "us-east-2b", "us-east-2c"]
}

module "public_sg" {
  source      = "./modules/security-group"
  vpc_id      = module.vpc.vpc_id
  name        = "doex10_public_sg"
  description = "security group for public server"

  ingress_rules = [
    {
      protocol    = "tcp"
      from_port   = 80
      to_port     = 80
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTP"
    },
    {
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTPS"
    }
  ]

  egress_rules = [
    {
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      cidr_blocks = ["0.0.0.0/0"]
      description = "allow all outbound traffic"
    }
  ]
}

module "private_sg" {
  source      = "./modules/security-group"
  vpc_id      = module.vpc.vpc_id
  name        = "doex10_private_sg"
  description = "security group for private server"

  ingress_rules = [
    {
      protocol    = "tcp"
      from_port   = 80
      to_port     = 80
      cidr_blocks = module.vpc.public_subnets_cidr
      description = "allow http from public subnets only"
    },
    {
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      cidr_blocks = module.vpc.public_subnets_cidr
      description = "allow https from public subnets only"
    }

  ]

  egress_rules = [
    {
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      cidr_blocks = ["0.0.0.0/0"]
      description = "allow outbound traffic"
    }
  ]
}

module "alb" {
  source              = "./modules/alb"
  alb_name            = "doex10-alb"
  is_internal         = false
  lb_type             = "application"
  sg                  = module.public_sg.security_group_id
  subnets             = module.vpc.public_subnet_ids
  deletion_protection = false
  target_port         = 80
  target_protocol     = "HTTP"
  vpc_id              = module.vpc.vpc_id
}

# ECR Module
module "my_ecr_repo" {
  source = "./modules/ecr"

  repository_name      = "flask-app"
  image_tag_mutability = "MUTABLE"
  scan_on_push         = true
  encryption_type      = "AES256"
  force_delete         = false

  lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = local.common_tags
}
# ECS Module
module "ecs" {
  source = "./modules/ecs-fargate" # Path to your ECS module

  # Basic Configuration
  project_name    = var.project_name
  cluster_name    = "${var.project_name}-cluster"
  service_name    = "flask-service"
  task_family     = "flask-task"
  container_name  = "flask-app"
  container_image = var.container_image
  container_port  = var.container_port

  # Resources
  cpu    = var.ecs_cpu
  memory = var.ecs_memory

  # Networking
  vpc_id                = module.vpc.vpc_id
  subnet_ids            = module.vpc.private_subnet_ids
  alb_security_group_id = module.public_sg.security_group_id
  assign_public_ip      = false # Using private subnets

  # Load Balancer
  target_group_arn = module.alb.target_group_arn

  # Auto Scaling
  desired_count             = var.ecs_desired_count
  auto_scaling_min_capacity = var.auto_scaling_min_capacity
  auto_scaling_max_capacity = var.auto_scaling_max_capacity
  cpu_target_value          = var.cpu_target_value
  memory_target_value       = var.memory_target_value
  scale_in_cooldown         = var.scale_in_cooldown
  scale_out_cooldown        = var.scale_out_cooldown

  # Health Check
  # health_check_command = "curl -f http://localhost:${var.container_port}${var.health_check_path} || exit 1"

  # Logging
  log_retention_days = var.log_retention_days

  environment_variables = var.environment_variables

  tags = local.common_tags
}

# Local values
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}