data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "Demo_site_vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  tags             = merge(var.common_tags, { Name = "${var.common_tags["Environment"]} demo vpc" })
}

resource "aws_subnet" "Demo_subnets" {
  count                   = length(var.subnets)
  vpc_id                  = aws_vpc.Demo_site_vpc.id
  cidr_block              = element(var.subnets, count.index)
  map_public_ip_on_launch = "true"
  availability_zone       = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]
  tags                    = merge(var.common_tags, { Name = "${var.common_tags["Environment"]} Demo subnet" })
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
