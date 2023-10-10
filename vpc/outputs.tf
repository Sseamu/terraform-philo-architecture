output "vpc_id" {
  value = aws_vpc.cluster_vpc.id
}

output "public_subnets" {
  value = aws_subnet.public_subnet.*.id
}

output "private_subnets" {
  value = aws_subnet.private_subnet.*.id
}
output "aws_availability_zone_available" {
  value = length(data.aws_availability_zones.available.names)
}
# output "public_subnet1_id" {
#   value = aws_subnet.public-subnet-1.id
# }

# output "private_subnet1_id" {
#   value = aws_subnet.private-subnet-1.id
# }

# output "private_subnet2_id" {
#   value = aws_subnet.private-subnet-2.id
# }
