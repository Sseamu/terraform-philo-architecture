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
  template = file("${path.module}/service.config.json.tpl")

  vars = {
    region                  = var.region
    aws_front_repository    = var.aws_ecr_front_repository
    aws_nginx_repository    = var.aws_ecr_nginx_repository
    aws_express_repository  = var.aws_ecr_express_repository
    tag                     = "latest"
    nginx_container_port    = var.nginx_container_port
    frontend_container_port = var.frontend_container_port
    express_container_port  = var.express_container_port
    application_name        = var.application_name
    service_type            = var.service_type
    registry_arn            = var.philoberry_discovery_service_arn
  }
}

resource "aws_ecs_task_definition" "service" {
  family                   = "service-staging-${var.service_type}"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = var.jenkins_ecs_task_role_arn
  cpu                      = 1024
  memory                   = 4096
  requires_compatibilities = ["FARGATE"]
  volume {
    name = "philoberry_home"
    efs_volume_configuration {
      file_system_id     = var.jenkins_efs_id
      root_directory     = "/"
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = var.jenkins_efs_access_point_id
        iam             = "ENABLED"
      }
    }
  }
  container_definitions = data.template_file.service.rendered


  tags = {
    Environment = "staging"
    Application = var.application_name
  }
}

resource "aws_ecs_service" "staging" {
  name                 = "staging"
  cluster              = var.cluster_arn //이내용을 main에있는 aws_Ecs_service에 모듈로 보내라
  task_definition      = aws_ecs_task_definition.service.arn
  desired_count        = var.aws_availablity_zones_count
  force_new_deployment = true
  launch_type          = "FARGATE"

  network_configuration {
    # security_groups  = [aws_security_group.ecs_tasks.id]
    security_groups  = var.ecs_task_sg
    subnets          = var.aws_private_subnets
    assign_public_ip = true //직접적으로 액세스 거부 
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_service.arn
    container_name   = "${var.application_name}_frontend"
    container_port   = var.frontend_container_port
  }
  health_check_grace_period_seconds = 300
  //서비스 시작후 일정시간동안 health_check생략


  depends_on = [
    var.http_listener,
    var.https_listener,
    aws_iam_role_policy_attachment.ecs_task_execution_role,
  ]
  service_registries {
    registry_arn = var.philoberry_discovery_service_arn
  }

  tags = {
    Environment = "staging"
    Application = "${var.application_name}_nginx"
  }
}



