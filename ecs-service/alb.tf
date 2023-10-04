resource "aws_lb_target_group" "ecs_service" {
  name = "${substr(var.application_name, 0, 10)}-${substr(md5("${var.application_port}${var.deregistration_delay}${var.healthcheck_matcher}"), 0, 12)}"

  port                 = 80
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = var.deregistration_delay

  health_check { //상태 검사
    enabled  = true
    path     = "/"    //상태 검사 경로
    protocol = "HTTP" //상태 검사 프로토콜   

    # 고급 상태 검사 설정 
    port                = "traffic-port" //트래픽 포트
    healthy_threshold   = 3              //정상 임계값
    unhealthy_threshold = 2              //비정상 임계값
    timeout             = 5              //제한 시간
    interval            = 10             //간격
    matcher             = "200"          //성공 코드
  }

  tags = {
    Name    = "philoberry-tg-${var.service_type}"
    Service = "philoberry-${var.service_type}"
  }
}
