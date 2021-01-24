#-----------------------------------------------
# My Terraform demo stand
#
# Made by Snyatkov V.
#
# e-mail: sniatkov@hotmail.com
# date: 23.01.2020
#----------------------------------------------

provider "aws" {}

#----------get ami data for Amazon linux----------------
data "aws_ami" "Amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"] # Canonical
}

#----------create EC2 and security group----------------
resource "aws_instance" "EC2_for_target_group" {
  ami                    = data.aws_ami.Amazon_linux.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.EC2_security.id]
  key_name               = "ssh_stockholm"
  tags = {
    Name    = "EC2_Amazon_for_TG"
    Project = "Demo-site"
    Owner   = "Snyatkov_V"
  }
  user_data = templatefile("user_data.tpl", {
    Owner   = "Snyatkov_V",
    Project = "Demo-site"
  })
}

resource "aws_security_group" "EC2_security" {
  name        = "SG port 80 8881 22"
  description = "Allow inbound traffic to 80, 22, 8881 ports"
  # vpc_id      = aws_vpc.main.id если не указать - будет в default

  ingress {
    description = "http from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "8881 from VPC"
    from_port   = 8881
    to_port     = 8881
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.Demo_site_vpc.cidr_block]
  }

  ingress {
    description = "22 from VPC"
    from_port   = 22
    to_port     = 22
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
    Name    = "SG ports 80 22 8881"
    Project = "Demo-site"
    Owner   = "Snyatkov_V"
  }
}

#-------- create VPC and subnet--------------------
resource "aws_vpc" "Demo_site_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name    = "Demo_site_vpc"
    Project = "Demo-site"
    Owner   = "Snyatkov_V"
  }
}

resource "aws_subnet" "Demo_site_subnet_1" {
  vpc_id                  = aws_vpc.Demo_site_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-north-1a"
  map_public_ip_on_launch = "true"
  tags = {
    Name    = "Demo_site_subnet_1"
    Project = "Demo-site"
    Owner   = "Snyatkov_V"
  }
}

resource "aws_subnet" "Demo_site_subnet_2" {
  vpc_id                  = aws_vpc.Demo_site_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-north-1b"
  map_public_ip_on_launch = "true"
  tags = {
    Name    = "Demo_site_subnet_2"
    Project = "Demo-site"
    Owner   = "Snyatkov_V"
  }
}
