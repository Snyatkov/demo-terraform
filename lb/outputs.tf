output "lb_tg_arn" {
  value = aws_lb_target_group.TG_for_demo_site.arn
}

output "lb_dns_name" {
  value = aws_lb.ALB_for_demo_site.dns_name
}

output "lb_zone_id" {
  value = aws_lb.ALB_for_demo_site.zone_id
}
