output "vpc_cidr" {
  value = aws_vpc.Demo_site_vpc.cidr_block
}
output "vpc_id" {
  value = aws_vpc.Demo_site_vpc.id
}

output "subnet_1" {
  value = aws_subnet.Demo_site_subnet_1.id
}
output "subnet_2" {
  value = aws_subnet.Demo_site_subnet_2.id
}
