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
############## frontend setting ########
data "template_file" "frontend" {
  template = file("${path.module}/frontend.json.tpl")

  vars = {
    region                  = var.region
    aws_front_repository    = var.aws_ecr_front_repository
    tag                     = "latest"
    frontend_container_port = var.frontend_container_port
    application_name        = var.application_name
    service_type            = var.service_type
    registry_arn            = var.frontend_discovery_service_arn
  }
}
resource "aws_ecs_task_definition" "frontend" {
  family                   = "frontend-staging-${var.service_type}"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.philoberry_ecs_task.arn
  cpu                      = 2048
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
  container_definitions = data.template_file.frontend.rendered


  tags = {
    Environment = "frontend"
    Application = var.application_name
  }
}

resource "aws_ecs_service" "frontend" {
  name                 = "frontend-service-${var.service_type}"
  cluster              = var.cluster_arn //이내용을 main에있는 aws_Ecs_service에 모듈로 보내라
  task_definition      = aws_ecs_task_definition.frontend.arn
  desired_count        = var.scaling_min_capacity
  force_new_deployment = true
  launch_type          = "FARGATE"

  network_configuration {
    security_groups  = var.frontend_task_sg
    subnets          = var.aws_private_subnets
    assign_public_ip = true //직접적으로 액세스 거부 
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend_service.arn
    container_name   = "${var.application_name}_frontend"
    container_port   = var.frontend_container_port
  }
  health_check_grace_period_seconds = 120
  //서비스 시작후 일정시간동안 health_check생략
  depends_on = [
    var.http_listener,
    var.https_listener,
    aws_iam_role_policy_attachment.ecs_task_execution_role,
  ]
  service_registries {
    registry_arn = var.frontend_discovery_service_arn
  }

  tags = {
    Environment = "frontend"
    Application = "${var.application_name}_frontend"
  }
}
#################### backend  ################

data "template_file" "backend" {
  template = file("${path.module}/backend.json.tpl")

  vars = {
    region                 = var.region
    aws_express_repository = var.aws_ecr_express_repository
    tag                    = "latest"
    express_container_port = var.express_container_port
    application_name       = var.application_name
    service_type           = var.service_type
    registry_arn           = var.backend_discovery_service_arn // cloudmap setting
  }
}

resource "aws_ecs_task_definition" "backend" {
  family                   = "backend-staging-${var.service_type}"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.philoberry_ecs_task.arn
  cpu                      = 1024
  memory                   = 2048
  requires_compatibilities = ["FARGATE"]
  container_definitions    = data.template_file.backend.rendered


  tags = {
    Environment = "backend"
    Application = var.application_name
  }
}

resource "aws_ecs_service" "backend" {
  name                 = "backend-service-${var.service_type}"
  cluster              = var.cluster_arn //이내용을 main에있는 aws_Ecs_service에 모듈로 보내라
  task_definition      = aws_ecs_task_definition.backend.arn
  desired_count        = var.scaling_min_capacity
  force_new_deployment = true
  launch_type          = "FARGATE"

  network_configuration {
    security_groups  = var.backend_task_sg
    subnets          = var.aws_private_subnets
    assign_public_ip = false //직접적으로 액세스 거부 
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.express_service.arn // targetgroup 맞게 생성해야함.
    container_name   = "${var.application_name}_express"
    container_port   = var.express_container_port
  }
  health_check_grace_period_seconds = 120
  //서비스 시작후 일정시간동안 health_check생략
  depends_on = [
    var.http_listener,
    var.https_listener,
    aws_iam_role_policy_attachment.ecs_task_execution_role,
    # aws_lb_target_group.frontend_service
  ]
  service_registries {
    registry_arn = var.backend_discovery_service_arn // cloudmap backend 용으로 하나 생성 
  }

  tags = {
    Environment = "backend"
    Application = "${var.application_name}_express"
  }
}


########## nginx ####################

data "template_file" "nginx" {
  template = file("${path.module}/nginx.json.tpl")

  vars = {
    region               = var.region
    aws_nginx_repository = var.aws_ecr_nginx_repository
    tag                  = "latest"
    nginx_container_port = var.nginx_container_port
    application_name     = var.application_name
    service_type         = var.service_type
    registry_arn         = var.nginx_discovery_service_arn
  }
}


resource "aws_ecs_task_definition" "nginx" {
  family                   = "nginx-staging-${var.service_type}"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.philoberry_ecs_task.arn
  cpu                      = 256
  memory                   = 512
  requires_compatibilities = ["FARGATE"]
  container_definitions    = data.template_file.nginx.rendered


  tags = {
    Environment = "nginx"
    Application = var.application_name
  }
}

resource "aws_ecs_service" "nginx" {
  name                 = "nginx-service-${var.service_type}"
  cluster              = var.cluster_arn //이내용을 main에있는 aws_Ecs_service에 모듈로 보내라
  task_definition      = aws_ecs_task_definition.nginx.arn
  desired_count        = var.scaling_min_capacity
  force_new_deployment = true
  launch_type          = "FARGATE"

  network_configuration {
    security_groups  = var.nginx_task_sg // nginx는 확인하고 해야할듯  ? 
    subnets          = var.aws_private_subnets
    assign_public_ip = false //직접적으로 액세스 거부 
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.nginx-service.arn // nginx는 로드밸런서 해줘야하나? 
    container_name   = "${var.application_name}_nginx"
    container_port   = var.nginx_container_port
  }
  health_check_grace_period_seconds = 120
  //서비스 시작후 일정시간동안 health_check생략
  depends_on = [
    var.aws_alb_arn
  ]
  service_registries {
    registry_arn = var.nginx_discovery_service_arn // cloudmap backend 용으로 하나 생성 
  }
  tags = {
    Environment = "nginx"
    Application = "${var.application_name}_nginx"
  }
}
