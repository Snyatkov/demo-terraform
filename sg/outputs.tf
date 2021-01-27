output "ec2_security_id" {
  value = aws_security_group.SG_for_EC2_instances.id
}
output "lb_security_id" {
  value = aws_security_group.SG_for_ALB.id
}
output "ecs_security_id" {
  value = aws_security_group.SG_for_ecs.id
}
