resource "aws_security_group" "ecs-cluster-sg" {
  name        = var.cluster_name
  vpc_id      = var.vpc_id
  description = var.cluster_name
}

resource "aws_security_group_rule" "cluster-egress" {
  security_group_id = aws_security_group.ecs-cluster-sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "cluster-allow-ssh" {
  count                    = var.enable_ssh ? 1 : 0
  security_group_id        = aws_security_group.ecs-cluster-sg.id
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = var.ssh_sg
}


resource "aws_security_group" "ecs_task" {
  vpc_id = var.vpc_id
  name   = "ecs-task-sg-${var.service_type}"
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
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "express_sg" {
  vpc_id = var.vpc_id
  name   = "express-sg"

  ingress {
    from_port       = var.express_port # Express 애플리케이션의 포트
    to_port         = var.express_port
    protocol        = "tcp"
    security_groups = [var.alb_sg]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
