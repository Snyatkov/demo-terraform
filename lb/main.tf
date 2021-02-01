#---TG for EC2 Demo-site
resource "aws_lb_target_group" "TG_for_demo_site" {
  name                 = "TG-for-demo-site"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = 10
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 10
    timeout             = 2
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  tags = merge(var.common_tags, { Name = "${var.common_tags["Environment"]} TG for EC2" })
}

#---TG for lambda
resource "aws_lb_target_group" "TG_for_demo_lambda" {
  name                 = "TG-for-demo-lambda"
  vpc_id               = var.vpc_id
  target_type          = "lambda"
  deregistration_delay = 10
  tags                 = merge(var.common_tags, { Name = "${var.common_tags["Environment"]} TG for lambda" })
}

#---TG for ECS
resource "aws_lb_target_group" "TG_for_ecs" {
  name                 = "TG-for-ecs"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  target_type          = "ip"
  deregistration_delay = 10
  health_check {
    healthy_threshold   = "3"
    interval            = "300"
    protocol            = "HTTP"
    matcher             = "200-299"
    timeout             = "20"
    path                = "/"
    unhealthy_threshold = "2"
  }
  tags = merge(var.common_tags, { Name = "${var.common_tags["Environment"]} TG for ECS" })
}

resource "aws_lb_target_group_attachment" "TG-attachement-for-demo-lambda" {
  target_group_arn = aws_lb_target_group.TG_for_demo_lambda.arn
  target_id        = var.lambda_arn
  depends_on       = [var.lambda_permission]
}

resource "aws_lb" "ALB_for_demo_site" {
  name               = "alb-for-demo-site"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.lb_security_id
  subnets            = var.subnets
  tags               = merge(var.common_tags, { Name = "${var.common_tags["Environment"]} ALB for demo" })
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
  listener_arn = aws_lb_listener.LB_listener_for_demo_site_443.arn
  priority     = 100
  condition {
    host_header {
      values = ["lambda.snyatkov.site"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.TG_for_demo_lambda.arn
  }
}

resource "aws_lb_listener_rule" "Rule_LB_listener_ecs" {
  listener_arn = aws_lb_listener.LB_listener_for_demo_site_443.arn
  priority     = 90
  condition {
    host_header {
      values = ["docker.snyatkov.site"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.TG_for_ecs.arn
  }
}
