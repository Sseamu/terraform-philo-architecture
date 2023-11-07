output "vpc_id" {
  value = aws_vpc.cluster_vpc.id
}

output "public_subnets" {
  value = aws_subnet.public_subnet.*.id
}

output "private_subnets" {
  value = aws_subnet.private_subnet.*.id
}
# output "aws_availability_zone_available" {
#   value = length(data.aws_availability_zones.available.names)
# } 실제로 사용할 값 
output "aws_availability_zone_available" {
  value = max(0, length(data.aws_availability_zones.available.names) - 2)
} // 임시 빌드중 task 개수 줄이기위해

