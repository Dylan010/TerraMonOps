# main.tf
provider "aws" {
  region = var.region
}

# VPC
resource "aws_vpc" "monitoring_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "Monitoring-VPC"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "monitoring_igw" {
  vpc_id = aws_vpc.monitoring_vpc.id

  tags = {
    Name = "Monitoring-IGW"
  }
}

# Subnet
resource "aws_subnet" "monitoring_subnet" {
  vpc_id                  = aws_vpc.monitoring_vpc.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "Monitoring-Subnet"
  }
}

# Route Table
resource "aws_route_table" "monitoring_rt" {
  vpc_id = aws_vpc.monitoring_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.monitoring_igw.id
  }

  tags = {
    Name = "Monitoring-RouteTable"
  }
}

# Route Table Association
resource "aws_route_table_association" "monitoring_rta" {
  subnet_id      = aws_subnet.monitoring_subnet.id
  route_table_id = aws_route_table.monitoring_rt.id
}

# Security Group
resource "aws_security_group" "monitoring_sg" {
  name        = "Monitoring-SG"
  description = "Allow inbound traffic for monitoring"
  vpc_id      = aws_vpc.monitoring_vpc.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Metrics exporter"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Monitoring-SG"
  }
}

# Key Pair
resource "tls_private_key" "monitoring_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "monitoring_key_pair" {
  key_name   = var.key_name
  public_key = tls_private_key.monitoring_key.public_key_openssh
}

resource "local_file" "monitoring_private_key" {
  content  = tls_private_key.monitoring_key.private_key_pem
  filename = "${path.module}/${var.key_name}.pem"
  file_permission = "0400"
}

# EC2 Instances
resource "aws_instance" "monitoring_instance" {
  count                  = var.instance_count
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.monitoring_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.monitoring_sg.id]
  subnet_id              = aws_subnet.monitoring_subnet.id

  tags = {
    Name = "Monitoring-Instance-${count.index + 1}"
  }
}

