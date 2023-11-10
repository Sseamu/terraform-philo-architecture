# VPC
variable "vpc_id" {
  type = string
}

variable "public_subnets" {
  type = list(any)
}

# 서비스 타입
variable "service_type" {
  type = string
}

# DB 인스턴스 클래스
variable "instance_class" {
  type = string
}

variable "username" {
  description = "RDS database username"
  type        = string
  default     = ""
}

variable "rds_password" {
  description = "RDS password"
  type        = string
  default     = ""
}

//퍼블릭액세스 가능
variable "publicly_accessible" {
  type = bool
}


variable "express_sg" {

}
