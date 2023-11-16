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
