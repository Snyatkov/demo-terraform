variable "subnets" {
  type = list(any)
}
variable "ecs_security_id" {
  type = list(any)
}
variable "tg_for_ecs" {}
variable "lb_listener_443" {}
variable "common_tags" {
  type = map(any)
}
