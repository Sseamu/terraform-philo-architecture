#terraform version
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  #   backend "s3" {
  #     bucket  = "philoberry-ecs-architecture"
  #     key     = "terraform.tfstate"
  #     region  = "ap-northeast-2"
  #     encrypt = true
  #   }
}

#AWS 리전(서울)
provider "aws" {
  region = "ap-northeast-2"
}

module "vpc" {
  source       = "./vpc"
  az_count     = 2
  service_type = var.service_type
}

#route53
module "route53" {
  source       = "./route53"
  domain       = var.domain
  zone_id      = module.alb.zone_id
  alb_dns_name = module.alb.alb_dns_name
}

#logs 

module "logs" {
  source         = "./logs"
  service_type   = var.service_type
  bucket_logs    = "ecs-access-logs-philoberry-${var.service_type}"
  elb_account_id = var.elb_account_id
  account_id     = var.account_id
}


#S3 

# module "s3" {
#   source       = "./s3"
#   service_type = var.service_type
#   vpc_id       = module.vpc.vpc_id
#   bucket       = "philoberry-s3-${var.service_type}"

# }

# rds
# module "rds" {
#   source              = "./rds"
#   service_type        = var.service_type
#   vpc_id              = module.vpc.vpc_id
#   subnet_ids          = [module.vpc.private_subnets]
#   instance_class      = "db.t3.micro"
#   username            = var.username
#   rds_password        = var.rds_password
#   publicly_accessible = false
# }


data "aws_caller_identity" "current" {

} //호출자의 신원정보를 가져오거나 참조하기 위한 것



module "ecs-cluster" {
  source         = "./ecs-cluster"
  vpc_id         = module.vpc.vpc_id
  service_type   = var.service_type
  cluster_name   = "philoberry-ecs-cluster"
  vpc_subnets    = module.vpc.private_subnets
  enable_ssh     = true
  ssh_sg         = aws_security_group.allow_ssh.id
  ssh_key_name   = var.key_pair_name
  log_group      = "my-log-group"
  aws_account_id = data.aws_caller_identity.current.account_id
  aws_region     = "ap-northeast-2"
}

module "ecr" {
  source       = "./ecr"
  service_type = var.service_type
}


module "ecs-service" {
  source                      = "./ecs-service"
  vpc_id                      = module.vpc.vpc_id
  aws_private_subnets         = module.vpc.private_subnets
  aws_ecr_front_repository    = module.ecr.aws_ecr_front_repository
  aws_ecr_nginx_repository    = module.ecr.aws_ecr_nginx_repository
  cluster_arn                 = module.ecs-cluster.cluster_arn
  service_role_arn            = module.ecs-cluster.service_role_arn
  service_type                = var.service_type
  tpl_path                    = var.tpl_path
  aws_availablity_zones_count = module.vpc.aws_availability_zone_available
  ecs_task_sg                 = module.ecs-cluster.ecs_task_sg
  http_listener               = module.alb.http_listener
  https_listener              = module.alb.https_listener
}

//log driver use 
//https://docs.aws.amazon.com/ko_kr/AmazonECS/latest/userguide/using_awslogs.html


#alb

module "alb" {
  source             = "./alb"
  service_type       = var.service_type
  vpc_id             = module.vpc.vpc_id
  alb_name           = "my-ecs-lb"
  vpc_subnets        = module.vpc.private_subnets
  default_target_arn = module.ecs-service.target_group_arn
  domain             = var.domain
  internal           = false
  subnet_ids         = module.vpc.public_subnets
  ecs_sg             = module.ecs-cluster.cluster_sg
  certificate_arn    = module.route53.acm_certificate_arn
}

#alb-rule

module "alb-rule" {
  source           = "./alb-rule"
  listener_arn     = module.alb.http_listener_arn
  priority         = 100
  target_group_arn = module.ecs-service.target_group_arn
  condition_field  = "host-header"
  condition_values = ["www.philoberry.com"]
}

