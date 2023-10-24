variable "listener_arn" {
}

variable "priority" {
}

variable "target_group_arn" {
}

variable "condition_field" {
}

variable "condition_values" {
  description = "List of condition values"
  type        = list(map(list(string)))
  default = [
    {
      "values" = ["www.philoberry.com"]
    }
  ]
}

