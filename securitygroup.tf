resource "aws_security_group" "allow_ssh_rds" {
  vpc_id      = module.vpc.vpc_id //main.tf 의 module에서 관리할 것이기에 이렇게함
  name        = "allow-ssh"
  description = "security group that allows SSh and egress traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH Tcp access Rule"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH Access Rule"
  }

  tags = {
    Name = "allow-ssh"
  }
}
