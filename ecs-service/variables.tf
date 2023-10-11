variable "vpc_id" {

}
variable "service_type" {
  type = string
}

variable "tpl_path" {
  type = string
}
variable "aws_private_subnets" {
  type = list(any)
}

variable "aws_availablity_zones_count" {
  type = number
}

variable "nginx_container_port" {
  type    = number
  default = 80
}

variable "frontend_container_port" {
  type    = number
  default = 443
}
variable "nginx_host_port" {
  type    = number
  default = 0
}
variable "frontend_host_port" {
  type    = number
  default = 0
}
variable "cluster_name" {
  type    = string
  default = "philoberry-ecs-cluster"
}

variable "aws_ecr_repository" {
  type = string
}

variable "application_name" {
  type    = string
  default = "philoberry-repository"
}

variable "deregistration_delay" {
  type    = number
  default = 30
}

variable "region" {
  type    = string
  default = "ap-northeast-2"
}

variable "ecs_task_sg" {
  type = list(string)
}
## alb vairiables

variable "cluster_arn" {
  description = "The ARN of the ECS cluster"
  type        = string
}

variable "service_role_arn" {
  description = "The ARN of the ECS service role"
  type        = string
}

variable "https_listener" {

}

variable "http_listener" {

}

variable "scaling_max_capacity" {
  type    = number
  default = 3
}
variable "scaling_min_capacity" {
  type    = number
  default = 1
}

variable "cpu_or_memory_limit" {
  type    = number
  default = 70
}
