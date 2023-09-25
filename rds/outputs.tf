# RDS 엔드포인트
output "rds_endpoint" {
  value = aws_db_instance.rds.endpoint
}

output "username" {
  value = aws_db_instance.rds.username
}

output "rds_password" {
  value = aws_db_instance.rds.password
}
