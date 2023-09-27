resource "aws_lb_target_group" "ecs_service" {
  name = "${substr(var.application_name, 0, 10)}-${substr(md5("${var.application_port}${var.deregistration_delay}${var.healthcheck_matcher}"), 0, 12)}"

  port                 = var.application_port
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = var.deregistration_delay

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = "5"
    interval            = "30"
    path                = "/"
    matcher             = "200"
  }
}
