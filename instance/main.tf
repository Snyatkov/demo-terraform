#---Configuration for EC2 demo-site
resource "aws_launch_configuration" "LC_for_ALB" {
  name_prefix     = "EC2-LC-Demo-site-"
  image_id        = var.ami_id
  instance_type   = "t3.micro"
  security_groups = var.ec2_security_id
  user_data = templatefile("user_data.tpl", {
    Owner   = "Snyatkov_V",
    Project = "Demo-site"
  })
  key_name = "ssh_stockholm"
}

resource "aws_autoscaling_group" "ASG_for_ALB" {
  name                      = "ASG-${aws_launch_configuration.LC_for_ALB.name}"
  launch_configuration      = aws_launch_configuration.LC_for_ALB.name
  min_size                  = 2
  max_size                  = 2
  min_elb_capacity          = 2
  health_check_type         = "ELB"
  vpc_zone_identifier       = var.subnets
  target_group_arns         = var.lb_tg_arn
  default_cooldown          = 60
  health_check_grace_period = 40
  lifecycle {
    create_before_destroy = true
  }
  dynamic "tag" {
    for_each = {
      Name        = "EC2_for_demo_site"
      Owner       = "Snyatkov_V"
      Environment = "Production"
      Project     = "Demo-site"
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }

  }
}
