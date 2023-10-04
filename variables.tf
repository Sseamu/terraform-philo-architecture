# 서비스타입
variable "service_type" {
  type = string
}
variable "username" {
  description = "RDS database username"
  type        = string
}

variable "rds_password" {
  description = "RDS database password"
  type        = string
}

variable "key_pair_name" {
  description = "my-ec2-key-pair-name"
  type        = string
}

variable "aws_region" {
  description = "my-region"
  default     = "ap-northeast-2"
}
variable "certificate_arn" {
  description = "The ARN of the certificate"
  type        = string
}

