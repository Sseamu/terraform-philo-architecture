variable "github_token" {
  type = string
}

variable "ecs_cluster_name" {
  type = string
}

variable "front_ecs_service_name" {
  type = string
}
variable "backend_ecs_service_name" {
  type = string
}

variable "service_type" {
  type = string
}

variable "https_listener_arn" {
  type = string
}

variable "http_listener_arn" {
  type = string
}
variable "target_group_arn" {
  type = string
}
variable "express_target_group_arn" {
  type = string
}

variable "green_target_group_arn" {
  type = string
}
variable "green_express_target_group_arn" {
  type = string
}

variable "target_group_name" {
  type = string
}

variable "green_target_group_name" {
  type = string
}

variable "express_target_group_name" {
  type = string
}

variable "green_express_target_group_name" {
  type = string
}
