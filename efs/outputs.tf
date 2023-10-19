output "efs_arn" {
  value       = aws_efs_file_system.philberryt-efs.arn
  description = "Value of philoberry efs arn"
}

output "efs_id" {
  value       = aws_efs_file_system.philberryt-efs.id
  description = "Value of philoberry efs id"
}

output "efs_access_point_id" {
  value       = aws_efs_access_point.philoberry.id
  description = "Value of philoberry access point id"
}
output "philoberry_efs_sg" {
  value       = aws_security_group.efs_sg.id
  description = "Value of philoberry security group"
}
