variable "ami_id" {}

variable "ec2_security_id" {
  type = list(any)
}
variable "subnets" {
  type = list(any)
}
variable "lb_tg_arn" {
  type = list(any)
}
