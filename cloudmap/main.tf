resource "aws_service_discovery_private_dns_namespace" "philoberry" {
  name        = "local.com"
  description = "Private DNS namespace for my service"
  vpc         = var.vpc_id

  tags = {
    Name = "philoberry_ecs_contianer Cloud Map"
  }
}

resource "aws_service_discovery_service" "philoberry" {
  name        = "philoberry"
  description = "My philoberry discovery service"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.philoberry.id

    dns_records {
      ttl  = 15
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }

  tags = {
    Name = "philoberry Cloud Map"
  }
}
