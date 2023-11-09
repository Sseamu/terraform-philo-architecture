resource "aws_instance" "main" {
  ami                    = "ami-0e01e66dacaf1454d"
  instance_type          = "t3.micro"
  subnet_id              = var.vpc_main_subnet
  iam_instance_profile   = aws_iam_instance_profile.main.name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  tags = {
    Name = "main-instance"
  }
}

resource "aws_security_group" "ec2_sg" {
  name   = "ec2_sg"
  vpc_id = var.vpc_id
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    description = "install mysql bastionhost"
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  description = "session manager AWS transport "
  egress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"] //[aws_db_instance.default.address]
  }
} // you need to decrease port (ex. 443 or 3306 port)

# resource "aws_security_group" "rds_sg" {
#   name   = "rds_sg"
#   vpc_id = var.vpc_id

#   ingress {
#     from_port       = 3306
#     to_port         = 3306
#     protocol        = "tcp"
#     security_groups = [aws_security_group.ec2_sg.id]
#   }
# }


resource "aws_iam_role" "main" {
  name               = "main-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}



resource "aws_iam_policy" "ssm_start_session_policy" {
  name        = "ssm_start_session_policy"
  description = "Allows user to start SSM session"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VisualEditor0",
      "Effect": "Allow",
      "Action": "ssm:StartSession",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ssm_start_session_policy_attachment" {
  role       = aws_iam_role.main.name
  policy_arn = aws_iam_policy.ssm_start_session_policy.arn
}

resource "aws_iam_role_policy_attachment" "main" {
  role       = aws_iam_role.main.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.main.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


# resource "aws_iam_role_policy_attachment" "ssm_full_access_policy" {
#   role       = aws_iam_role.main.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
# }Rmain

resource "aws_iam_instance_profile" "main" {
  name = "main-profile"
  role = aws_iam_role.main.name
}
