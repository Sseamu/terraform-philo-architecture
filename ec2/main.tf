resource "aws_instance" "main" {
  ami                    = "ami-0e01e66dacaf1454d"
  instance_type          = "t3.micro"
  key_name               = var.key_name
  subnet_id              = var.vpc_main_subnet
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  tags = {
    Name = "rds-bastion-instance"
  }
}

resource "aws_security_group" "ec2_sg" {
  name   = "ec2_bastion_sg"
  vpc_id = var.vpc_id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# resource "aws_eip" "eip" {
#   instance = aws_instance.main.id
#   domain   = "vpc"

#   tags = {
#     Name    = "philoberry-bastion-eip-${var.service_type}"
#     Service = "philoberry-${var.service_type}"
#   }
# }
