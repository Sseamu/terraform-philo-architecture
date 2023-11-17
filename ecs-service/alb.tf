resource "aws_lb_target_group" "ecs_service" {
  name = "${substr(var.application_name, 0, 10)}-${var.service_type}"

  port                 = 80
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = var.vpc_id
  deregistration_delay = var.deregistration_delay

  health_check { //상태 검사
    enabled  = true
    path     = "/"    //상태 검사 경로
    protocol = "HTTP" //상태 검사 프로토콜   

    # 고급 상태 검사 설정 
    healthy_threshold   = 3     //정상 임계값
    unhealthy_threshold = 2     //비정상 임계값
    timeout             = 30    //제한 시간
    interval            = 60    //간격
    matcher             = "200" //성공 코드
  }

  tags = {
    Name    = "philoberry-tg-${var.service_type}"
    Service = "philoberry-${var.service_type}"
  }
}

resource "aws_lb_target_group" "express_service" {
  name = "${substr(var.application_name, 0, 10)}-express"

  port                 = 8000
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = var.vpc_id
  deregistration_delay = var.deregistration_delay

  health_check {
    enabled  = true
    path     = "/healthcheck"
    protocol = "HTTP"

    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 30
    interval            = 60
    matcher             = "200"
  }

  tags = {
    Name    = "philoberry-tg-express"
    Service = "philoberry-express"
  }
}

resource "aws_lb_target_group" "nginx-service" {
  name = "${substr(var.application_name, 0, 10)}-nginx"

  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
  health_check {
    interval            = 60
    enabled             = true
    path                = "/"
    timeout             = 30
    healthy_threshold   = 3
    unhealthy_threshold = 2
    protocol            = "HTTP"
    matcher             = "200-399"
  }
  tags = {
    Name    = "nginx-tg"
    Service = "philoberry-nginx"
  }
}
