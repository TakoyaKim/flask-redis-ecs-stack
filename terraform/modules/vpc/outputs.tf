output "vpc_id" {
  value = aws_vpc.cool.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "public_subnets_cidr" {
  value = aws_subnet.public[*].cidr_block
}