variable "service_type" {
  type = string
}
variable "az_count" {
  type = number
  //default = 2 az-a az-b
}

variable "region" {
  default = "ap-northeast-2"
  type    = string
}
