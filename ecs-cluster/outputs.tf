output "cluster_arn" {
  value = aws_ecs_cluster.cluster.id
}

output "service_role_arn" {
  value = aws_iam_role.cluster-service-role.arn
}

output "cluster_sg" {
  value = aws_security_group.ecs-cluster-sg.id
}
output "frontend_task_sg" {
  value = [aws_security_group.frontend_task.id]
}

output "backend_task_sg" {
  value = [aws_security_group.backend_task.id]
}

output "nginx_task_sg" {
  value = [aws_security_group.nginx_task.id]
}

# output "express_sg" {
#   value = aws_security_group.express_sg.id
# }
