output "target_group_arn" {
  value = aws_lb_target_group.ecs_service.arn
}
output "ecs_task_role_arn" {
  value       = aws_iam_role.jenkins_ecs_task.arn
  description = "Value of jenkins ecs task role arn"
}
