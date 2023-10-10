resource "aws_security_group" "ecs-cluster-sg" {
  name        = var.cluster_name
  vpc_id      = var.vpc_id
  description = var.cluster_name
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

resource "aws_security_group_rule" "cluster-egress" {
  security_group_id = aws_security_group.ecs-cluster-sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group" "ecs_task" {
  vpc_id = var.vpc_id
  name   = "ecs-task-sg-${var.service_type}"
  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

}
