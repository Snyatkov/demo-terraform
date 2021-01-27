#-----------------------------------------------
# My Terraform demo stand
#
# Made by Snyatkov V.
#
# e-mail: sniatkov@hotmail.com
# date: 23.01.2020
#----------------------------------------------

provider "aws" {}

terraform {
  backend "s3" {
    bucket = "demo-site-bucket-state"
    key    = "terraform.tfstate"
    region = "eu-north-1"
  }
}

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

data "aws_ami" "Amazon_ecs" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn-ami*amazon-ecs-optimized"]
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

#----------------Create Application load balancer---------------
module "lb" {
  source            = "./lb"
  subnets           = [module.vpc.subnet_1, module.vpc.subnet_2]
  vpc_id            = module.vpc.vpc_id
  lb_security_id    = [module.sg.lb_security_id]
  certificate_arn   = data.aws_acm_certificate.issued.arn
  lambda_arn        = module.lambda.lambda_arn
  lambda_permission = module.lambda.lambda_permission
}

#----------------Create launch conf and autoscaling_group--------
module "instance" {
  source          = "./instance"
  ami_id          = data.aws_ami.Amazon_linux.id
  ec2_security_id = [module.sg.ec2_security_id]
  subnets         = [module.vpc.subnet_1, module.vpc.subnet_2]
  lb_tg_arn       = [module.lb.lb_tg_arn]
}

#----------------Create VPC-------------------------------------
module "vpc" {
  source             = "./vpc"
  vpc_cidr           = "10.0.0.0/16"
  vpc_availible_zone = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
}

#----------------Create Security groups------------------------
module "sg" {
  source   = "./sg"
  vpc_cidr = [module.vpc.vpc_cidr]
  vpc_id   = module.vpc.vpc_id
}


#---------------Manage route 53-------------------------------
module "r53" {
  source      = "./r53"
  r53_id      = "Z02027932QK6EFEPPT3W2"
  lb_dns_name = module.lb.lb_dns_name
  lb_zone_id  = module.lb.lb_zone_id
  for_each    = toset(["ec2.snyatkov.site", "docker.snyatkov.site", "elb.snyatkov.site", "lambda.snyatkov.site"])
  record_name = each.key
}

#--------------Create Lambda function---------------------------
module "lambda" {
  source             = "./lambda"
  tg_for_demo_lambda = module.lb.tg_for_demo_lambda
}

#--------------Create ECS--------------------------------------
module "ecs" {
  source          = "./ecs"
  subnets         = [module.vpc.subnet_1, module.vpc.subnet_2]
  ecs_security_id = [module.sg.ecs_security_id]
  tg_for_ecs      = module.lb.tg_for_ecs
  lb_listener_443 = module.lb.lb_listener_443
}
