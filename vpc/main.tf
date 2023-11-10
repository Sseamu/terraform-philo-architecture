# vpc 설정
resource "aws_vpc" "cluster_vpc" {
  cidr_block           = "172.18.0.0/16"
  instance_tenancy     = "default" ## 테넌시-기본값
  enable_dns_hostnames = true

  tags = {
    Name    = "philoberry-cluster_vpc-${var.service_type}"
    Service = "philoberry-{var.service_type}"
  }
}

data "aws_availability_zones" "available" {

} // 작성이유: 특정지역내의 가용영역 검색을 위해 사용 동적으로 가져와 다른리소스에 사용됨


# 퍼블릭 서브넷

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.cluster_vpc.id
  count                   = var.az_count
  cidr_block              = cidrsubnet(aws_vpc.cluster_vpc.cidr_block, 8, var.az_count + count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "ecs-public-subnet-${var.service_type}"
  }
}


# 프라이빗 서브넷
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.cluster_vpc.id
  count             = var.az_count
  cidr_block        = cidrsubnet(aws_vpc.cluster_vpc.cidr_block, 8, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    name = "ecs-private-subnet-${var.service_type}"
  }
}

#internetgateway
resource "aws_internet_gateway" "cluster_igw" {
  vpc_id = aws_vpc.cluster_vpc.id

  tags = {
    Name = "ecs-igw-${var.service_type}"
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.cluster_vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.cluster_igw.id
}

resource "aws_eip" "nat_gateway" {
  count      = var.az_count
  domain     = "vpc"
  depends_on = [aws_internet_gateway.cluster_igw]
}

resource "aws_nat_gateway" "nat_gateway" {
  count         = var.az_count
  subnet_id     = element(aws_subnet.public_subnet.*.id, count.index)
  allocation_id = element(aws_eip.nat_gateway.*.id, count.index)

  tags = {
    Name = "NAT gw ${var.service_type}"
  }
}

resource "aws_route_table" "private_route" {
  count  = var.az_count
  vpc_id = aws_vpc.cluster_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.nat_gateway.*.id, count.index)
  }

  tags = {
    Name = "private-route-table-${var.service_type}"
  }
}

resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.cluster_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cluster_igw.id
  }

  tags = {
    Name = "ecs-route-table-${var.service_type}"
  }
}


resource "aws_route_table_association" "to-public" {
  count          = length(aws_subnet.public_subnet)
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = element(aws_route_table.public_route.*.id, count.index)
}

resource "aws_route_table_association" "to-private" {
  count          = length(aws_subnet.private_subnet)
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = element(aws_route_table.private_route.*.id, count.index)
}


# // endpooint_security_group
# resource "aws_security_group" "endpoint_sg" {
#   name        = "endpoint_sg"
#   description = "Allow inbound traffic on port 443"
#   vpc_id      = aws_vpc.cluster_vpc.id

#   ingress {
#     description = "HTTPS"
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "endpoint_sg"
#   }
# }



// vpc end point setting 
// ssm , ssmmessages, ec2messages, s3 loging
# SSM
# resource "aws_vpc_endpoint" "ssm_endpoint" {
#   vpc_id             = aws_vpc.cluster_vpc.id
#   service_name       = "com.amazonaws.${var.region}.ssm"
#   vpc_endpoint_type  = "Interface"
#   security_group_ids = [aws_security_group.endpoint_sg.id]
#   subnet_ids         = [aws_subnet.private_subnet[0].id]

#   tags = {
#     Name = "ssm_endpoint"
#   }
# }

# # SSM Messages
# resource "aws_vpc_endpoint" "ssmmessages_endpoint" {
#   vpc_id             = aws_vpc.cluster_vpc.id
#   service_name       = "com.amazonaws.${var.region}.ssmmessages"
#   vpc_endpoint_type  = "Interface"
#   security_group_ids = [aws_security_group.endpoint_sg.id]
#   subnet_ids         = [aws_subnet.private_subnet[0].id]

#   tags = {
#     Name = "ssmmessages_endpoint"
#   }
# }

# # EC2 Messages
# resource "aws_vpc_endpoint" "ec2messages_endpoint" {
#   vpc_id             = aws_vpc.cluster_vpc.id
#   service_name       = "com.amazonaws.${var.region}.ec2messages"
#   vpc_endpoint_type  = "Interface"
#   security_group_ids = [aws_security_group.endpoint_sg.id]
#   subnet_ids         = [aws_subnet.private_subnet[0].id]

#   tags = {
#     Name = "ec2messages_endpoint"
#   }
# }

# # S3
# resource "aws_vpc_endpoint" "s3_endpoint" {
#   vpc_id            = aws_vpc.cluster_vpc.id
#   service_name      = "com.amazonaws.${var.region}.s3"
#   vpc_endpoint_type = "Gateway"
#   tags = {
#     Name = "s3_endpoint"
#   }
# }

# # CloudWatch Logs
# resource "aws_vpc_endpoint" "logs_endpoint" {
#   vpc_id             = aws_vpc.cluster_vpc.id
#   service_name       = "com.amazonaws.${var.region}.logs"
#   vpc_endpoint_type  = "Interface"
#   security_group_ids = [aws_security_group.endpoint_sg.id]
#   subnet_ids         = [aws_subnet.private_subnet[0].id]

#   tags = {
#     Name = "logs_endpoint"
#   }
# }
