resource "aws_vpc" "cool" {

  # Create a VPC with the specified CIDR block
  cidr_block = var.vpc_cidr

  # Name of the VPC
  tags = {
    Name = var.vpc_name
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  count                   = var.create_public_subnet ? length(var.public_subnets) : 0 
  vpc_id                  = aws_vpc.cool.id                                           
  cidr_block              = var.public_subnets[count.index]                           
  availability_zone       = var.azs[count.index % length(var.azs)]     
  map_public_ip_on_launch = true                                                      
  tags                    = { Name = "Public Subnet ${count.index + 1}" }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.cool.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.azs[count.index % length(var.azs)]
  tags = {
    Name = "private subnet ${count.index + 1}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.cool.id
  tags   = { Name = "${var.vpc_name}-igw" }
}

# Elastic IPs for NAT
resource "aws_eip" "nat" {

  count  = length(var.azs)
  domain = "vpc"

}

# NAT Gateways
resource "aws_nat_gateway" "nat" {

  count         = var.create_public_subnet ? length(var.azs) : 0
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  depends_on    = [aws_internet_gateway.igw]
  tags          = { Name = "${var.vpc_name}-nat-${count.index}" }

}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.cool.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.vpc_name}-public-rt"
  }
}

# Private Route Tables
resource "aws_route_table" "private" {
  count  = length(var.azs)
  vpc_id = aws_vpc.cool.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[count.index].id
  }
  tags = {
    Name = "${var.vpc_name}-private-rt-${count.index}"
  }
}

# Route Table Associations
resource "aws_route_table_association" "public" {
  count          = var.create_public_subnet ? length(var.public_subnets) : 0
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index % length(aws_route_table.private)].id
}