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
  #container_definitions    = file("container-definitions/container.json")
  container_definitions = jsonencode([{
    name      = "demo-ecs"
    image     = "984547102228.dkr.ecr.eu-north-1.amazonaws.com/demo1:v2"
    essential = true
    #environment = var.container_environment
    portMappings = [{
      protocol      = "tcp"
      containerPort = 80
      hostPort      = 80
    }]
  }])
  tags = {
    Name        = "ECS_task_for_demo"
    Owner       = "Snyatkov_V"
    Environment = "Production"
    Project     = "Demo-ecs"
  }
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

  tags = {
    Name        = "ECS_service_for_demo"
    Owner       = "Snyatkov_V"
    Environment = "Production"
    Project     = "Demo-ecs"
  }
}

resource "aws_ecs_cluster" "demo_ecs" {
  name = "demo_ecs"
}
