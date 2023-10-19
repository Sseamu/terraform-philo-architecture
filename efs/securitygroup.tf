resource "aws_security_group" "efs_sg" {
  name        = "efs_sg"
  vpc_id      = var.vpc_id
  description = "Security group for EFS"

  ingress {
    from_port   = 2049 # NFS port
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # replace with your CIDR blocks or security groups
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
