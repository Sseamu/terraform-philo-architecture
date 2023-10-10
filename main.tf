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
  service_type = var.service_type
}

#route53
module "route53" {
  source       = "./route53"
  domain       = var.domain
  zone_id      = module.alb.zone_id
  alb_dns_name = module.alb.alb_dns_name
}


#S3 

# module "s3" {
#   source       = "./s3"
#   service_type = var.service_type
#   vpc_id       = module.vpc.vpc_id
#   bucket       = "philoberry-s3-${var.service_type}"

# }

#rds
# module "rds" {
#   source              = "./rds"
#   service_type        = var.service_type
#   vpc_id              = module.vpc.vpc_id
#   private_subnet1_id  = module.vpc.private_subnet1_id
#   private_subnet2_id  = module.vpc.private_subnet2_id
#   instance_class      = "db.t3.micro"
#   username            = var.username
#   rds_password        = var.rds_password
#   publicly_accessible = false
# }


data "aws_caller_identity" "current" {

} //호출자의 신원정보를 가져오거나 참조하기 위한 것



module "ecs-cluster" {
  source       = "./ecs-cluster"
  vpc_id       = module.vpc.vpc_id
  service_type = var.service_type
  cluster_name = "philoberry-ecs-cluster"
  # instance_type = "t2.small" //이전에는 module에 가능했는데 지금은 참조하는 곳에서 사용하면 안되는듯?
  ssh_key_name = var.key_pair_name
  vpc_subnets  = [module.vpc.private_subnet1_id, module.vpc.private_subnet2_id] // join(",", module.vpc.public_subnets) 이건 서브넷이 여러개일때 사용하기 적합 현재
  //내 아키텍쳐는 퍼블릭 서브넷이 1개이기 때문에 여러개는 불필요 
  enable_ssh     = true
  ssh_sg         = aws_security_group.allow_ssh.id
  log_group      = "my-log-group"
  aws_account_id = data.aws_caller_identity.current.account_id
  aws_region     = var.aws_region
}

module "ecs-service" {
  source                      = "./ecs-service"
  vpc_id                      = module.vpc.vpc_id
  application_name            = "philoberry-repository2" // ecr_repository를 새로 생성하네? 
  application_port            = 443
  nginx_version               = "ver-2"
  frontend_version            = "ver-1"
  cluster_arn                 = module.ecs-cluster.cluster_arn
  service_role_arn            = module.ecs-cluster.service_role_arn
  aws_region                  = var.aws_region
  cpu_reservation             = 2048
  memory_reservation          = 5096
  desired_count               = 2
  alb_arn                     = module.ecs-service.target_group_arn // 아직 진행안했음.
  service_type                = var.service_type
  cpu_reservation_frontend    = 5096
  memory_reservation_frontend = 10192
  log_group_nginx             = "/aws/ecs/philoberry-repository2/nginx-log-group"
  log_group_frontend          = "/aws/ecs/philoberry-repository2/frontend-log-group"
}

//log driver use 
//https://docs.aws.amazon.com/ko_kr/AmazonECS/latest/userguide/using_awslogs.html


#alb

module "alb" {
  source             = "./alb"
  service_type       = var.service_type
  vpc_id             = module.vpc.vpc_id
  alb_name           = "my-ecs-lb"
  vpc_subnets        = [module.vpc.private_subnet1_id, module.vpc.private_subnet2_id]
  default_target_arn = module.ecs-service.target_group_arn
  domain             = var.domain
  internal           = false
  subnet_ids         = [module.vpc.public_subnet1_id]
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

