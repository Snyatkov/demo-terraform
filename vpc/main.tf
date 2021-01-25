resource "aws_vpc" "Demo_site_vpc" {
  cidr_block       = var.vpc_cidr
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
  availability_zone       = var.vpc_availible_zone[0]
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
  availability_zone       = var.vpc_availible_zone[1]
  map_public_ip_on_launch = "true"
  tags = {
    Name    = "Demo_site_subnet_2"
    Project = "Demo-site"
    Owner   = "Snyatkov_V"
  }
}
