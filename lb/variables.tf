variable "subnets" {
  type = list(any)
}
variable "vpc_id" {}
variable "lb_security_id" {
  type = list(any)
}
variable "certificate_arn" {}
