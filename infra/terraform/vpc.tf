data "aws_availability_zones" "available" { state = "available" }

//set the number of AZs to use
locals {
  azs_count = 2
  azs_names = data.aws_availability_zones.available.names
}

# VPC for Jenkins
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "Jenkins VPC"
  }
}

# Subnets in the VPC
resource "aws_subnet" "public" {
  count             = local.azs_count
  vpc_id            = aws_vpc.main.id
  availability_zone = local.azs_names[count.index]
  //cidr_block = 10.0.10.0/24 & 10.0.11.0/24
  cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, 10 + count.index)
  //TODO maybe set to false if we use a NAT Gateway for agents
  map_public_ip_on_launch = true
}

# Allow traffic to the internet
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}
# Route Tables for the subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "public" {
  count          = local.azs_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}


# TODO Look if we should use a NAT Gateway and block traffic form the internet

# Security Groups for the subnets
# Allow traffic from the internet to 8080 and 22
resource "aws_security_group" "jenkins-controller" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["${var.home_IP}/32", "${var.office_IP}/32"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.home_IP}/32", "${var.office_IP}/32", aws_vpc.main.cidr_block]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.home_IP}/32", "${var.office_IP}/32", ]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# TODO Look if we can lock down traffic between Jenkins contoller and agents
