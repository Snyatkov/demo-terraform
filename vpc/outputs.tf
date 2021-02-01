output "vpc_cidr" {
  value = aws_vpc.Demo_site_vpc.cidr_block
}
output "vpc_id" {
  value = aws_vpc.Demo_site_vpc.id
}
output "subnets" {
  value = aws_subnet.Demo_subnets
}
