output "cluster_arn" {
  value = aws_ecs_cluster.cluster.id
}

output "service_role_arn" {
  value = aws_iam_role.cluster-service-role.arn
}

output "cluster_sg" {
  value = aws_security_group.ecs-cluster-sg.id
}
output "ecs_task_sg" {
  value = [aws_security_group.ecs_task.id]
}
