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

