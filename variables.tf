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


variable "domain" {
  type = string
}


variable "tpl_path" {
  type = string
}

variable "account_id" {
  type = string
}

variable "elb_account_id" {
  type = string
}
