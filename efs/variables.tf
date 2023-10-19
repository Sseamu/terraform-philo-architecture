variable "philoberry_efs_sg_id" {
  type        = string
  description = "Value of philoberry efs securiy_group id"
}
variable "aws_private_subnets" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}
