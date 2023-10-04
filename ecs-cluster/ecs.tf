#ECS ami

data "aws_ami" "ecs" {
  most_recent = true // 가장 최근의 ami 검색

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["591542846629"] # amazon AWS 계정 id 
}

# ECS cluster

resource "aws_ecs_cluster" "cluster" {
  name = var.cluster_name
}

# launch config
resource "aws_launch_configuration" "cluster" {
  name_prefix          = "ecs-${var.service_type}-launch_config"
  image_id             = data.aws_ami.ecs.id
  instance_type        = "t3.small"
  key_name             = var.ssh_key_name //tfvars 에있음
  iam_instance_profile = aws_iam_instance_profile.cluster-ec2-role.id
  security_groups      = [aws_security_group.ecs-cluster-sg.id]
  user_data = templatefile("${path.module}/templates/ecs_init.tpl", {
    cluster_name = var.cluster_name
  })
  lifecycle {
    create_before_destroy = true // 리소스 업데이트시 동작제어 
    //리소스를 업데이트하기전에 새로운 리소스 생성 기존 리소스 삭제(중복 방지 및 변경사항 안전하게 적용)
  }
  metadata_options {
    http_endpoint = "enabled" //
    http_tokens   = "required"
  }
}

#AutoScaling
resource "aws_autoscaling_group" "cluster" {
  name                 = "ecs-${var.service_type}-autoscaling"
  vpc_zone_identifier  = var.vpc_subnets
  launch_configuration = aws_launch_configuration.cluster.name
  termination_policies = split(",", var.ecs_termination_policies)
  min_size             = var.ecs_minsize
  max_size             = var.ecs_maxsize
  desired_capacity     = var.ecs_desired_capacity

  tag {
    key                 = "Name"
    value               = "${var.service_type}-ecs"
    propagate_at_launch = true
    // Auto Scaling 그룹에서 EC2 인스턴스에 대한 태그를 생성하거나 업데이트할 때 해당 태그가 새로운 인스턴스에도 전파되도록 지정하는 옵션입니다.
  }
}

