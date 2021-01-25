resource "aws_security_group" "SG_for_ALB" {
  name   = "SG_for_ALB"
  vpc_id = var.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "EC2_security" {
  name        = "SG_port_80_8881_22"
  description = "Allow inbound traffic to 80, 22, 8881 ports"
  vpc_id      = var.vpc_id

  ingress {
    description = "http from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.vpc_cidr
  }

  ingress {
    description = "8881 from VPC"
    from_port   = 8881
    to_port     = 8881
    protocol    = "tcp"
    cidr_blocks = var.vpc_cidr
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
