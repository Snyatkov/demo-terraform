resource "aws_elastic_beanstalk_application" "demo-elb" {
  name = var.ELB_name
}

resource "aws_elastic_beanstalk_environment" "tfenvtest" {
  name                = var.ELB_name
  application         = aws_elastic_beanstalk_application.demo-elb.name
  solution_stack_name = var.ELB_env_type
}
