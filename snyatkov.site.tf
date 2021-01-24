#-----------------------------------------------
# My Terraform demo stand
#
# Made by Snyatkov V.
#
# e-mail: sniatkov@hotmail.com
# date: 23.01.2020
#----------------------------------------------

provider "aws" {}

#----------get data from AWS---------------------
data "aws_ami" "Amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_acm_certificate" "issued" {
  domain   = "*.snyatkov.site"
  statuses = ["ISSUED"]
}

#----------------output-----------------------------------------
/*output "aws_acm_certificate" {
  value = data.aws_acm_certificate.issued.arn
}*/
#----------------Create environments for ALB---------------------


resource "aws_lb_target_group" "TG_for_demo_site" {
  name     = "tg-for-demo-site"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.Demo_site_vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb" "ALB_for_demo_site" {
  name               = "alb-for-demo-site"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.SG_for_ALB.id]
  subnets            = [aws_subnet.Demo_site_subnet_1.id, aws_subnet.Demo_site_subnet_2.id]
  tags = {
    Name    = "ALB for demo site"
    Project = "Demo-site"
    Owner   = "Snyatkov_V"
  }
}

resource "aws_lb_listener" "LB_listener_for_demo_site" {
  load_balancer_arn = aws_lb.ALB_for_demo_site.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "LB_listener_for_demo_site_443" {
  load_balancer_arn = aws_lb.ALB_for_demo_site.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.issued.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.TG_for_demo_site.arn
  }
}

resource "aws_lb_listener_rule" "Rule_LB_listener" {
  listener_arn = aws_lb_listener.LB_listener_for_demo_site.arn
  priority     = 100
  condition {
    host_header {
      values = ["ec2.snyatkov.site"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.TG_for_demo_site.arn
  }
}



resource "aws_launch_configuration" "LC_for_ALB" {
  name_prefix     = "EC2-LC-Demo-site-"
  image_id        = data.aws_ami.Amazon_linux.id
  instance_type   = "t3.micro"
  security_groups = [aws_security_group.EC2_security.id]
  user_data = templatefile("user_data.tpl", {
    Owner   = "Snyatkov_V",
    Project = "Demo-site"
  })
  key_name = "ssh_stockholm"
  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_autoscaling_group" "ASG_for_ALB" {
  name                 = "ASG-${aws_launch_configuration.LC_for_ALB.name}"
  launch_configuration = aws_launch_configuration.LC_for_ALB.name
  min_size             = 2
  max_size             = 2
  min_elb_capacity     = 2
  health_check_type    = "ELB"
  vpc_zone_identifier  = [aws_subnet.Demo_site_subnet_1.id, aws_subnet.Demo_site_subnet_2.id]
  target_group_arns    = [aws_lb_target_group.TG_for_demo_site.arn]
  lifecycle {
    create_before_destroy = true
  }
  dynamic "tag" {
    for_each = {
      Name    = "EC2_for_demo_site"
      Owner   = "Snyatkov_V"
      Project = "Demo-site"
      TAGKEY  = "TAGVALUE"
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }

  }
}


#--------------Security groups--------------------------

resource "aws_security_group" "SG_for_ALB" {
  name   = "SG_for_ALB"
  vpc_id = aws_vpc.Demo_site_vpc.id
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
  vpc_id      = aws_vpc.Demo_site_vpc.id #если не указать - будет в default

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

resource "aws_route" "add_route_to_IGT" {
  route_table_id         = aws_vpc.Demo_site_vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.IGW_for_demo_site.id
}

resource "aws_internet_gateway" "IGW_for_demo_site" {
  vpc_id = aws_vpc.Demo_site_vpc.id

  tags = {
    Name    = "IGW_for_demo_site"
    Project = "Demo-site"
    Owner   = "Snyatkov_V"
  }
}

resource "aws_subnet" "Demo_site_subnet_1" {
  vpc_id                  = aws_vpc.Demo_site_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
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
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = "true"
  tags = {
    Name    = "Demo_site_subnet_2"
    Project = "Demo-site"
    Owner   = "Snyatkov_V"
  }
}
