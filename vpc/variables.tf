variable "vpc_cidr" {
  type = string
}
variable "common_tags" {
  type = map(any)
}
variable "subnets" {
  type = list(any)
}
