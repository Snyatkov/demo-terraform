variable "vpc_cidr" {
  type = string
}
variable "vpc_availible_zone" {
  type = list(any)
}
variable "common_tags" {
  type = map(any)
}
