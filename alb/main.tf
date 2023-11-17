#ECS 로드밸런서
resource "aws_lb" "alb" {
  name            = var.alb_name                //로드밸런서 이름
  internal        = var.internal                //체계 : 인터넷 경계, IPv4
  security_groups = [aws_security_group.alb.id] //보안 그룹 alb.securitygroup
  subnets         = var.vpc_subnets             //네트워크 매핑

  enable_deletion_protection = false //삭제 방지 - 비활성화

  tags = {
    Name    = "philoberry_alb-${var.service_type}"
    Service = "philoberry_alb-${var.service_type}"
  }
}

#리스너 및 라우팅  80번 포트 


resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.alb.arn //로드밸런서
  port              = "80"           //포트
  protocol          = "HTTP"         //프로토콜


  default_action {
    type = "redirect" //다음으로 전달
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
# https 프로토콜 
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.alb.arn //로드밸런서 
  port              = "443"          //포트
  protocol          = "HTTPS"        //프로토콜
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"            //다음으로 전달
    target_group_arn = var.target_group_arn //대상 그룹
  }
}

#express 리스너 (alb(nextjs 요청) => express에 들어오도록)
## api 요청
resource "aws_lb_listener_rule" "express_api_listener" {
  listener_arn = aws_lb_listener.https_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = var.express_target_group_arn #aws_lb_target_group.express_service.arn 
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}
##route 요청

resource "aws_lb_listener_rule" "express_route_listener" {
  listener_arn = aws_lb_listener.https_listener.arn
  priority     = 101

  action {
    type             = "forward"
    target_group_arn = var.express_target_group_arn #aws_lb_target_group.express_service.arn 
  }

  condition {
    path_pattern {
      values = ["/routes/*"]
    }
  }
}

## nginx 리스너
resource "aws_lb_listener_rule" "nginx" {
  listener_arn = aws_lb_listener.https_listener.arn

  action {
    type             = "forward"
    target_group_arn = var.target_group_arn //aws_lb_target_group.nginx-service.arn
  }

  condition {
    host_header {
      values = ["www.philoberry.com"]
    }
  }
}
