variable "log_group" {

}

variable "cluster_name" {

}

variable "aws_region" {

}

variable "vpc_id" {
  type = string
}

variable "aws_account_id" {

}

variable "service_type" {
  type = string
}

variable "vpc_subnets" {
  description = "ecs zone identifier Now 1area after 2area more"
  type        = list(string)
}

variable "ecs_termination_policies" {
  default = "OldestLaunchConfiguration,Default"
}

variable "ecs_minsize" {
  default = 1
}

variable "ecs_maxsize" {
  default = 1
}

variable "ecs_desired_capacity" {
  default = 1
}


variable "enable_ssh" {

}

variable "ssh_key_name" {

}

variable "ssh_sg" {
  default = ""
}

variable "log_retention_days" {
  description = "Number of days to retain log events"
  type        = number
  default     = 1
}
