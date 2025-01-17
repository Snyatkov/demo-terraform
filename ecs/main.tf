data "aws_iam_policy_document" "ecs_task_execution_role" {
  version = "2012-10-17"
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecs-demo-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "ecs_service" {
  family                   = "demo-ecs"
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  requires_compatibilities = ["FARGATE"]
  container_definitions = jsonencode([{
    name      = "demo-ecs"
    image     = "984547102228.dkr.ecr.eu-north-1.amazonaws.com/demo1:v3"
    essential = true
    logConfiguration : {
      logDriver : "awslogs",
      options : {
        awslogs-region : "eu-north-1",
        awslogs-stream-prefix : "demo_ecs",
        awslogs-group : "demo_ecs_cloudwatch"
      }
    },
    portMappings = [{
      protocol      = "tcp"
      containerPort = 80
      hostPort      = 80
    }]
  }])
  tags = merge(var.common_tags, { Name = "${var.common_tags["Environment"]} ECS task for demo ECS" })
}

resource "aws_ecs_service" "demo_ecs_service" {
  name            = "demo_ecs_service"
  cluster         = aws_ecs_cluster.demo_ecs.id
  task_definition = aws_ecs_task_definition.ecs_service.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = var.ecs_security_id
    subnets          = var.subnets
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.tg_for_ecs
    container_name   = "demo-ecs"
    container_port   = 80
  }

  depends_on = [var.lb_listener_443, aws_iam_role_policy_attachment.ecs_task_execution_role]
  tags       = merge(var.common_tags, { Name = "${var.common_tags["Environment"]} ECS service for demo ECS" })
}

resource "aws_ecs_cluster" "demo_ecs" {
  name = "demo_ecs"
  tags = merge(var.common_tags, { Name = "${var.common_tags["Environment"]} ECS cluster for demo ECS" })
}

resource "aws_cloudwatch_log_group" "demo_ecs_cloudwatch" {
  name = "demo_ecs_cloudwatch"
  tags = merge(var.common_tags, { Name = "${var.common_tags["Environment"]} cloudwatch for demo ECS" })
}
