resource "aws_lb_target_group" "TG_for_demo_site" {
  name     = "tg-for-demo-site"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb" "ALB_for_demo_site" {
  name               = "alb-for-demo-site"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.lb_security_id
  subnets            = var.subnets
  tags = {
    Name    = "ALB for demo site"
    Project = "Demo-site"
    Owner   = "Snyatkov_V"
  }
}

resource "aws_lb_listener" "LB_listener_for_demo_site" {
  load_balancer_arn = aws_lb.ALB_for_demo_site.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "LB_listener_for_demo_site_443" {
  load_balancer_arn = aws_lb.ALB_for_demo_site.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.TG_for_demo_site.arn
  }
}

resource "aws_lb_listener_rule" "Rule_LB_listener" {
  listener_arn = aws_lb_listener.LB_listener_for_demo_site.arn
  priority     = 100
  condition {
    host_header {
      values = ["ec2.snyatkov.site"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.TG_for_demo_site.arn
  }
}