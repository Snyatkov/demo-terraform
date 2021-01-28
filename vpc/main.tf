resource "aws_vpc" "Demo_site_vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  tags             = merge(var.common_tags, { Name = "${var.common_tags["Environment"]} demo vpc" })
}

resource "aws_subnet" "Demo_site_subnet_1" {
  vpc_id                  = aws_vpc.Demo_site_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = var.vpc_availible_zone[0]
  map_public_ip_on_launch = "true"
  tags                    = merge(var.common_tags, { Name = "${var.common_tags["Environment"]} demo subnet 1" })
}

resource "aws_subnet" "Demo_site_subnet_2" {
  vpc_id                  = aws_vpc.Demo_site_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = var.vpc_availible_zone[1]
  map_public_ip_on_launch = "true"
  tags                    = merge(var.common_tags, { Name = "${var.common_tags["Environment"]} demo subnet 2" })
}

resource "aws_internet_gateway" "IGW_for_demo_site_vpc" {
  vpc_id = aws_vpc.Demo_site_vpc.id
  tags   = merge(var.common_tags, { Name = "${var.common_tags["Environment"]} IGT for demo" })
}

resource "aws_route" "add_route_to_IGT" {
  route_table_id         = aws_vpc.Demo_site_vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.IGW_for_demo_site_vpc.id
}
