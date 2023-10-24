resource "aws_lb_listener_rule" "alb_rule" {
  listener_arn = var.listener_arn
  priority     = var.priority

  action {
    type             = "forward"
    target_group_arn = var.target_group_arn
  }

  dynamic "condition" {
    for_each = var.condition_values
    content {

      dynamic "host_header" {
        for_each = var.condition_field == "host-header" ? [1] : []
        content {
          values = condition.value["values"]
        }
      }

      dynamic "path_pattern" {
        for_each = var.condition_field == "path-pattern" ? [1] : []
        content {
          values = condition.value["values"]
        }
      }

      # 추가적인 조건 필드들...
    }
  }

}
