variable "log_group" {
  description = "The name of the CloudWatch log group"
  type        = string
}

variable "cluster_name" {

}

variable "aws_region" {
  description = "The region in which to deploy the resources"
  type        = string
}

variable "vpc_id" {
  type = string
}

variable "aws_account_id" {
  description = "The AWS account ID"
  type        = string
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
  default = 4
}

variable "ecs_desired_capacity" {
  default = 1
}


# variable "enable_ssh" {

# }



# variable "ssh_sg" {
#   default = ""
# }
variable "ssh_key_name" {

}


variable "log_retention_days" {
  description = "Number of days to retain log events"
  type        = number
  default     = 1
}

variable "front_port" {
  type    = list(number)
  default = [3000]
}

variable "backend_port" {
  type    = number
  default = 8000
}

variable "express_port" {
  type    = number
  default = 8000
}

variable "alb_sg" {

}
