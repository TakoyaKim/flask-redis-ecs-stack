variable "vpc_id" {

  description = "The ID of the VPC where the security group will be created"
  type        = string

}

variable "name" {

  description = "The name of the security group"
  type        = string
  default     = "default-security-group"

}

variable "description" {

  description = "A description for the security group"
  type        = string
  default     = "Default security group for default resources"

}

variable "ingress_rules" {

  description = "List of ingress rules for the security group"
  type = list(object({
    protocol    = string
    from_port   = number
    to_port     = number
    cidr_blocks = list(string)
    description = string
  }))
  default = []

}

variable "egress_rules" {

  description = "List of egress rules for the security group"
  type = list(object({
    protocol    = string
    from_port   = number
    to_port     = number
    cidr_blocks = list(string)
    description = string
  }))
  default = []

}