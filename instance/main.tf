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
  max_size                  = 4
  desired_capacity          = 2
  health_check_type         = "ELB"
  vpc_zone_identifier       = var.subnets
  target_group_arns         = var.lb_tg_arn
  default_cooldown          = 60
  health_check_grace_period = 40
  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]
  lifecycle {
    create_before_destroy = true
  }
  dynamic "tag" {
    for_each = {
      Name        = "EC2 for demo"
      Owner       = "Snyatkov_V"
      Environment = "Production"
      Project     = "Demo"
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

#---Manage scale up and scale down
resource "aws_autoscaling_policy" "ASG_demo_site_policy_up" {
  name                   = "ASG_demo_site_policy_up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.ASG_for_ALB.name
}

resource "aws_cloudwatch_metric_alarm" "ASG_demo_site_cpu_alarm_up" {
  alarm_name          = "ASG_demo_site_cpu_alarm_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.ASG_for_ALB.name
  }

  alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions     = [aws_autoscaling_policy.ASG_demo_site_policy_up.arn]
}

resource "aws_autoscaling_policy" "ASG_demo_site_policy_down" {
  name                   = "ASG_demo_site_policy_down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.ASG_for_ALB.name
}

resource "aws_cloudwatch_metric_alarm" "ASG_demo_site_cpu_alarm_down" {
  alarm_name          = "ASG_demo_site_cpu_alarm_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "10"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.ASG_for_ALB.name
  }

  alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions     = [aws_autoscaling_policy.ASG_demo_site_policy_down.arn]
}
