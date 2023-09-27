variable "vpc_id" {

}


variable "containers" {
  description = "Containers in container definition"
  default     = []
  type = list(object({
    application_name    = string
    host_port           = number
    application_port    = number
    additional_ports    = list(string)
    application_version = string
    ecr_url             = string
    cpu_reservation     = number
    memory_reservation  = number
    command             = list(string)
    links               = list(string)
    docker_labels       = map(string)
    dependsOn = list(object({
      containerName = string
      condition     = string
    }))
    mountpoints = list(object({
      containerPath = string
      sourceVolume  = string
      readOnly      = bool
    }))
    secrets = list(object({
      name      = string
      valueFrom = string
    }))
    environments = list(object({
      name  = string
      value = string
    }))
    environment_files = list(object({
      value = string
      type  = string
    }))
  }))
}

variable "existing_ecr" {
  default = ""
}

variable "ecr_prefix" {
  default = ""
}

variable "application_name" {
  type = string
}

variable "aws_region" {

}
variable "log_group" {
  type = string
}


variable "application_version" {
  type = string
}
variable "application_port" {
  type = number
}


variable "cpu_reservation" {

}
variable "memory_reservation" {

}

variable "task_role_arn" {
  default = ""
}
variable "desired_count" {

}
variable "alb_arn" {

}

variable "deployment_minimum_healthy_percent" {
  default = 100
}

variable "deployment_maximum_percent" {
  default = 200
}

variable "deregistration_delay" {
  default = 30
}

variable "healthcheck_matcher" {
  default = "200"
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
