output "cluster_arn" {
  value = aws_ecs_cluster.cluster.id
}

output "service_role_arn" {
  value = aws_iam_role.cluster-service-role.arn
}


