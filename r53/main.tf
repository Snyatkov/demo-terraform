#---Add record to ALB
resource "aws_route53_record" "ec2" {
  zone_id = var.r53_id
  name    = var.record_name
  type    = "A"
  alias {
    name                   = var.lb_dns_name
    zone_id                = var.lb_zone_id
    evaluate_target_health = true
  }
}
