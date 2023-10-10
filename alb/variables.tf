#default vpc
variable "vpc_id" {
  type = string
}

#서비스 타입
variable "service_type" {
  type = string
}

#서브넷
variable "subnet_ids" {
  type = list(any)
}

# https 프로토콜 certication_arn
variable "certificate_arn" {
  description = "The Arn of the Certificate"
  type        = string
}
#########################
variable "alb_name" {

}

variable "internal" {

}

variable "domain" {

}

variable "default_target_arn" {

}

variable "ecs_sg" {
  default = ""
}

variable "vpc_subnets" {
  type = set(string)
}

variable "port" {
  type    = list(number)
  default = [80, 443]
}

