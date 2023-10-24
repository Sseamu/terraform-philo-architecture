resource "aws_security_group" "alb" {
  name        = var.alb_name
  vpc_id      = var.vpc_id
  description = var.alb_name

  dynamic "ingress" {
    for_each = var.port
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "cluster-allow-alb" {
  # count                    = length(var.ecs_sg)
  # security_group_id        = element(var.ecs_sg, count.index)
  security_group_id        = var.ecs_sg
  type                     = "ingress"
  from_port                = 32768
  to_port                  = 61000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
}

