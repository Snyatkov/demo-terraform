variable "codedeploy_application_name" {}
variable "lb_name" {}
variable "autoscaling_groups" {
  type = list(any)
}
