resource "aws_lb" "alb" {
  name                       = var.alb_name
  internal                   = var.is_internal
  load_balancer_type         = var.lb_type
  security_groups            = [var.sg]
  subnets                    = var.subnets
  enable_deletion_protection = var.deletion_protection
}

resource "aws_lb_target_group" "tg" {
  name     = "${var.alb_name}-tg"
  port     = var.target_port
  protocol = var.target_protocol
  target_type = "ip"
  vpc_id   = var.vpc_id

  health_check {
    enabled = true
    healthy_threshold = 2
    interval = 30
    matcher = "200"
    path = var.health_check_path
    port = "traffic-port"
    protocol = "HTTP"
    timeout = 5
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = var.target_port
  protocol          = var.target_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}