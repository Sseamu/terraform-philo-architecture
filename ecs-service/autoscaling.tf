resource "aws_appautoscaling_target" "target" {
  max_capacity       = var.scaling_max_capacity
  min_capacity       = var.scaling_min_capacity
  resource_id        = "service/${var.cluster_arn}/${aws_ecs_service.frontend.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "scale_up" {
  name               = "scale-up"
  service_namespace  = aws_appautoscaling_target.target.service_namespace
  scalable_dimension = aws_appautoscaling_target.target.scalable_dimension
  resource_id        = aws_appautoscaling_target.target.resource_id
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    target_value       = 75.0
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}

resource "aws_appautoscaling_policy" "scale_down" {
  name               = "scale-down"
  service_namespace  = aws_appautoscaling_target.target.service_namespace
  scalable_dimension = aws_appautoscaling_target.target.scalable_dimension
  resource_id        = aws_appautoscaling_target.target.resource_id
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    target_value       = 25.0
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}
