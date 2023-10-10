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
  name               = "ecs-staging-execution-role-${var.service_type}"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "template_file" "service" {
  template = file(var.tpl_path)

  vars = {
    region             = var.region
    aws_ecr_repository = var.aws_ecr_repository
    tag                = "latest"
    container_port     = join(",", [for p in var.container_port : tostring(p)])
    host_port          = var.host_port
    application_name   = var.application_name
    service_type       = var.service_type
  }
}

resource "aws_ecs_task_definition" "service" {
  family                   = "service-staging-${var.service_type}"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  cpu                      = 1024
  memory                   = 2048
  requires_compatibilities = ["FARGATE"]
  container_definitions    = data.template_file.service.rendered

  tags = {
    Environment = "staging"
    Application = var.application_name
  }
}

resource "aws_ecs_cluster" "staging" {
  name = "service-ecs-cluster-${var.service_type}"
}

resource "aws_ecs_service" "staging" {
  name                 = "staging"
  cluster              = aws_ecs_cluster.staging.id
  task_definition      = aws_ecs_task_definition.service.arn
  desired_count        = var.aws_availablity_zones_count
  force_new_deployment = true
  launch_type          = "FARGATE"

  network_configuration {
    # security_groups  = [aws_security_group.ecs_tasks.id]
    security_groups  = var.ecs_task_sg
    subnets          = var.aws_private_subnets
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_service.arn
    container_name   = var.application_name
    container_port   = var.container_port[1] //front server port
  }

  depends_on = [
    var.http_listener,
    var.https_listener,
    aws_iam_role_policy_attachment.ecs_task_execution_role,
  ]

  tags = {
    Environment = "staging"
    Application = var.application_name
  }
}



