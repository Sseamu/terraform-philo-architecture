output "frontend_discovery_service_arn" {
  value       = aws_service_discovery_service.frontend.arn
  description = "aws_Service Discovery service arn"
}

output "backend_discovery_service_arn" {
  value       = aws_service_discovery_service.backend.arn
  description = "aws_Service Discovery service arn"
}

output "nginx_discovery_service_arn" {
  value       = aws_service_discovery_service.nginx.arn
  description = "aws_Service Discovery service arn"
}
