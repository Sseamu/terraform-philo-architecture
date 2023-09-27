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
  vpc_subnets  = [module.vpc.private_subnet1_id] // join(",", module.vpc.public_subnets) 이건 서브넷이 여러개일때 사용하기 적합 현재
  //내 아키텍쳐는 퍼블릭 서브넷이 1개이기 때문에 여러개는 불필요 
  enable_ssh     = true
  ssh_sg         = aws_security_group.allow_ssh.id
  log_group      = "my-log-group"
  aws_account_id = data.aws_caller_identity.current.account_id
  aws_region     = var.AWS_REGION
}

module "ecs-service" {
  source = "./ecs-service"
}














#alb

module "alb" {
  source       = "./alb"
  service_type = var.service_type
  vpc_id       = module.vpc.vpc_id



  subnet_ids = [module.vpc.public_subnet1_id] //ECS 컨테이너에 로드밸런싱
}
