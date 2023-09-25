# vpc 설정
resource "aws_vpc" "vpc" {
  cidr_block           = "172.18.0.0/16"
  instance_tenancy     = "default" ## 테넌시-기본값
  enable_dns_hostnames = true

  tags = {
    Name    = "philoberry-vpc-${var.service_type}"
    Service = "philoberry-{var.service_type}"
  }
}



# 퍼블릭 서브넷1

resource "aws_subnet" "public-subnet-1" {
  vpc_id                  = aws_vpc.vpc.id    // VPC ID
  cidr_block              = "172.18.0.0/24"   //CIDR block
  availability_zone       = "ap-northeast-2a" //가용영역
  map_public_ip_on_launch = true
  tags = {
    Name    = "philoberry-public-subnet-1-${var.service_type}"
    Service = "philoberry-{var.servic_type}"
  }
}


# 프라이빗 서브넷1
resource "aws_subnet" "private-subnet-1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "172.18.1.0/24"
  availability_zone = "ap-northeast-2a"
  tags = {
    Name    = "philoberry-private-subnet-1-${var.service_type}"
    Service = "philoberry-${var.service_type}"
  }
}
# 프라이빗 서브넷2
resource "aws_subnet" "private-subnet-2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "172.18.2.0/24"
  availability_zone = "ap-northeast-2b"
  tags = {
    Name    = "philoberry-private-subnet-2-${var.service_type}"
    Service = "philoberry-${var.service_type}"
  }
}



#Internet Gateway

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id // 현재 사용가능한 vpc
  tags = {
    Name    = "philoberry-igw-${var.service_type}"
    Service = "philoberry-${var.service_type}"
  }
}

# EIP 할당
resource "aws_eip" "eip_1" {
  #   vpc = true ==> 예전버전에 사용하던 방식
  domain = "vpc"
  tags = {
    Name    = "philoberry-natgw-eip_1-${var.service_type}"
    Service = "philoberry-${var.service_type}"
  }
}


# NAT gateway
resource "aws_nat_gateway" "natgw_1" {
  allocation_id = aws_eip.eip_1.id              //탄력적 IP 할당 ID
  subnet_id     = aws_subnet.public-subnet-1.id //퍼블릭 서브넷 1

  tags = {
    Name    = "philoberry-natgw-public1-${var.service_type}"
    Service = "philoberry-${var.service_type}"
  }
}


# 퍼블릭 라우팅 테이블 연동 
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"                 //Destination (대상)
    gateway_id = aws_internet_gateway.igw.id //Target (대상)
  }

  tags = {
    Name    = "philoberry-public-rt-${var.service_type}" //라우팅 테이블 이름
    Service = "philoberry-${var.service_type}"
  }
}

#프라이빗 라우팅 테이블 연동
resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"                //Destination (대상)
    gateway_id = aws_nat_gateway.natgw_1.id //Target (대상)
  }

  tags = {
    Name    = "philoberry-private-rt-${var.service_type}"
    Service = "philoberry-${var.service_type}"
  }
}

#퍼블릭 라우팅 테이블에 퍼블릭 서브넷1 연결

resource "aws_route_table_association" "public-rt-association-1" {
  subnet_id      = aws_subnet.public-subnet-1.id
  route_table_id = aws_route_table.public-rt.id
}

#프라이빗 라이팅 테이블에 프라이빗 서브넷 1 연결
resource "aws_route_table_association" "private-rt-association-1" {
  subnet_id      = aws_subnet.private-subnet-1.id
  route_table_id = aws_route_table.private-rt.id
}

#프라이빗 라이팅 테이블에 프라이빗 서브넷 2 연결
resource "aws_route_table_association" "private-rt-association-2" {
  subnet_id      = aws_subnet.private-subnet-2.id
  route_table_id = aws_route_table.private-rt.id
}
