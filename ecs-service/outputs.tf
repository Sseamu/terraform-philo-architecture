output "target_group_arn" {
  value = aws_lb_target_group.frontend_service_blue.arn
}

output "target_group_name" {
  value = aws_lb_target_group.frontend_service_blue.name
}

output "green_target_group_arn" {
  value = aws_lb_target_group.frontend_service_green.arn
}

output "green_target_group_name" {
  value = aws_lb_target_group.frontend_service_green.name
}

# output "ecs_task_role_arn" {
#   value       = aws_iam_role.philoberry_ecs_task.arn
#   description = "Value of philoberry ecs task role arn"
# }

output "express_target_group_arn" {
  value = aws_lb_target_group.express_service_blue.arn
}

output "express_target_group_name" {
  value = aws_lb_target_group.express_service_blue.name
}

output "green_express_target_group_arn" {
  value = aws_lb_target_group.express_service_green.arn
}

output "green_express_target_group_name" {
  value = aws_lb_target_group.express_service_green.name
}

# output "nginx_target_group_arn" {
#   value = aws_lb_target_group.nginx-service.arn
# }
output "frontend_service_name" {
  value = aws_ecs_service.frontend.name
}

output "backend_service_name" {
  value = aws_ecs_service.backend.name
}
