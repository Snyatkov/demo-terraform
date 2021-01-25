output "ec2_security_id" {
  value = aws_security_group.EC2_security.id
}
output "lb_security_id" {
  value = aws_security_group.SG_for_ALB.id
}
