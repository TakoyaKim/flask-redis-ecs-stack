# This module creates security groups for the VPC

# Create the security group
resource "aws_security_group" "cool_sg" {

  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id

  # Ingress rules
  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      protocol    = ingress.value.protocol
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }

  # Egress rules
  dynamic "egress" {
    for_each = var.egress_rules
    content {
      protocol    = egress.value.protocol
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      cidr_blocks = egress.value.cidr_blocks
      description = egress.value.description
    }
  }

  tags = {

    Name = var.name

  }
}