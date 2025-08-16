resource "aws_service_discovery_http_namespace" "namespace" {
  name = "${var.cluster_name}-namespace"
  description = "Service Connect namespace for Flask Redis app"

  tags = var.tags
}

resource "aws_ecs_cluster" "cluster" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = var.tags
}

resource "aws_ecs_task_definition" "redis" {
  family = "redis-service"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "256"
  memory = "512"
  execution_role_arn = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name = "redis"
      image = "redis:7-alpine"
      portMappings = [
        {
          name = "redis-port"
          containerPort = 6379
          protocol = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.redis_logs.name
          "awslogs-region"        = data.aws_region.current.id
          "awslogs-stream-prefix" = "redis"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "redis" {
  name            = "redis-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.redis.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.redis.id]
    assign_public_ip = var.assign_public_ip
  }

  service_connect_configuration {
    enabled = true
    namespace = aws_service_discovery_http_namespace.namespace.arn

    service {
      port_name = "redis-port"
      discovery_name = "redis"

      client_alias {
        port = 6379
        dns_name = "redis"
      }
    }
  }

  depends_on = [aws_ecs_task_definition.redis]
  tags = var.tags
}

resource "aws_ecs_task_definition" "flask_task" {
  family                   = var.task_family
  cpu                      = var.cpu
  memory                   = var.memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn           = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = var.container_image
      essential = true
      
      portMappings = [
        {
          name          = "flask-port"  
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]
      
      environment = [
        {
          name  = "REDIS_HOST"
          value = "redis" 
        },
        {
          name  = "REDIS_PORT"
          value = "6379"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.flask_logs.name 
          "awslogs-region"        = data.aws_region.current.id
          "awslogs-stream-prefix" = "flask"
        }
      }
    }
  ])

  tags = var.tags
}

resource "aws_ecs_service" "flask_service" {  
  name            = var.service_name
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.flask_task.arn  
  desired_count   = var.desired_count
  launch_type     = "FARGATE"
  
  platform_version = "LATEST"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.flask.id]
    assign_public_ip = var.assign_public_ip
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  deployment_configuration {
    strategy = var.deployment_strategy
    bake_time_in_minutes = var.bake_time
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  # Prevent task definition changes from triggering service replacement
  lifecycle {
    ignore_changes = [task_definition]
  }

  service_connect_configuration {
    enabled = true
    namespace = aws_service_discovery_http_namespace.namespace.arn  # FIXED: Use .arn

    service {
      port_name = "flask-port"
      discovery_name = "flask-app"

      client_alias {
        port = var.container_port
        dns_name = "flask-app"
      }
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.ecs_execution_role_policy,
    aws_ecs_service.redis,
    aws_ecs_task_definition.redis
  ]

  tags = var.tags
}

# Execution Role (for ECS agent)
resource "aws_iam_role" "ecs_execution_role" {
  name = "${var.cluster_name}-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

# Task Role (for application)
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.cluster_name}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Redis security group
resource "aws_security_group" "redis" {
  name_prefix = "redis-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.flask.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "redis-security-group"
  })
}

# Flask Security Group
resource "aws_security_group" "flask" {
  name_prefix = "flask-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = var.container_port 
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "flask-security-group"
  })
}

# CloudWatch Log Group for Redis
resource "aws_cloudwatch_log_group" "redis_logs" {
  name              = "/ecs/${var.cluster_name}/redis"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

# CloudWatch Log Group for Flask
resource "aws_cloudwatch_log_group" "flask_logs" {
  name              = "/ecs/${var.cluster_name}/flask"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

# Data sources
data "aws_region" "current" {}

# Auto Scaling Target
resource "aws_appautoscaling_target" "ecs_target" {
  depends_on         = [aws_ecs_service.flask_service] 
  max_capacity       = var.auto_scaling_max_capacity
  min_capacity       = var.auto_scaling_min_capacity
  resource_id        = "service/${aws_ecs_cluster.cluster.name}/${aws_ecs_service.flask_service.name}"  
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  tags = var.tags
}

# CPU-based Auto Scaling Policy
resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  name               = "${var.service_name}-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = var.cpu_target_value
    scale_in_cooldown  = var.scale_in_cooldown
    scale_out_cooldown = var.scale_out_cooldown

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}

# Memory-based Auto Scaling Policy
resource "aws_appautoscaling_policy" "ecs_policy_memory" {
  name               = "${var.service_name}-memory-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = var.memory_target_value
    scale_in_cooldown  = var.scale_in_cooldown
    scale_out_cooldown = var.scale_out_cooldown

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
  }
}