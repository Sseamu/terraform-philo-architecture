variable "service_type" {
  type = string
}
variable "account_id" {
  type = string
}
variable "elb_account_id" {
  type = string
}

variable "bucket_logs" {
  type = string
}

variable "application_name" {
  type    = string
  default = "philoberry-repository"
}
