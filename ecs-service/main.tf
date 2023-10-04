#first we need to ECR

resource "aws_ecr_repository" "ecs-service" {
  count = length(var.containers) == 0 && var.existing_ecr == "" ? 1 : 0
  // var.containers가 비어있고 var.existing_ecr 변수가 비어있는 경우 ecr 리포지토리생성
  name = var.ecr_prefix == "" ? var.application_name : "${var.ecr_prefix}/{var.application_name}"
  image_scanning_configuration {
    scan_on_push = true
  } // 이미지 스캐닝은 Docker 이미지의 보안 취약점을 탐지하고 이러한 취약점을 예방하는 데 도움
}
# get latest active revision
#
data "aws_ecs_task_definition" "ecs-service" {
  task_definition = aws_ecs_task_definition.ecs-service-taskdef.family
  depends_on      = [aws_ecs_task_definition.ecs-service-taskdef]
}


# task definition template
locals {
  ecs_service_content = templatefile("${path.module}/ecs-service.json", {
    application_name            = var.application_name
    application_port            = var.application_port
    nginx_version               = var.nginx_version
    frontend_version            = var.frontend_version
    ecr_url                     = aws_ecr_repository.ecs-service[0].repository_url
    aws_region                  = var.aws_region
    cpu_reservation             = var.cpu_reservation
    memory_reservation          = var.memory_reservation
    cpu_reservation_frontend    = var.cpu_reservation_frontend
    memory_reservation_frontend = var.memory_reservation_frontend
    log_group_nginx             = var.log_group_nginx
    log_group_frontend          = var.log_group_frontend
  })
}

# task definition

resource "aws_ecs_task_definition" "ecs-service-taskdef" {
  family = var.application_name

  # Use the rendered content directly in the container_definitions attribute.
  container_definitions = local.ecs_service_content

  task_role_arn = var.task_role_arn

}


# task definition

resource "aws_ecs_service" "ecs-service" {
  name    = var.application_name
  cluster = var.cluster_arn
  task_definition = "${aws_ecs_task_definition.ecs-service-taskdef.family}:${max(
    aws_ecs_task_definition.ecs-service-taskdef.revision,
    data.aws_ecs_task_definition.ecs-service.revision,
  )}"
  iam_role                           = var.service_role_arn
  desired_count                      = var.desired_count
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.deployment_maximum_percent

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_service.id
    container_name   = "${var.application_name}_frontend" //fronted_loadbalaner
    container_port   = var.application_port
  }

  depends_on = [null_resource.alb_exists]
}

resource "null_resource" "alb_exists" {
  triggers = {
    alb_name = var.alb_arn
  }
}
