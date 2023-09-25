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
