# 보안 그륩
# 위치 : EC2 > 네트워크 및 보안 > 보안 그룹
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "rds_sg" {
  name        = "philoberry-rds-db-sg-${var.service_type}" //보안그룹이름을 서비스타입으로 구분하기위해서
  description = "philoberry rds-db security group production"
  vpc_id      = var.vpc_id
  # 인바운드 규칙   
  ingress {
    description     = "philoberry_rds_ingress"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.express_sg]
  }
  ingress {
    description     = "temporary_rds_ingress"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.bastion_sg]
  } //temporary rds_enter

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "philoberry-rds-db-sg-${var.service_type}"
    Service = "philoberry-rds-db-${var.service_type}"
  }
}

## snapshot 불러오기 
# data "aws_db_snapshot" "db_snapshot" {
#   most_recent            = true
#   db_instance_identifier = "philoberry-db-${var.service_type}" // 이전 DB 인스턴스 식별자
# }

# 서브넷 그룹 생성 (private subnet 2개)
# 위치 : RDS > 서브넷 그룹
## public subnet 2 에 해당하는 부분
resource "aws_db_subnet_group" "public-subnet-group" {
  name       = "philoberry-public-subnet-group-${var.service_type}"
  subnet_ids = var.public_subnets

  tags = {
    Name    = "philoberry-pulbic-subnet-group-${var.service_type}"
    Service = "philoberry-${var.service_type}"
  }
}

## private subnet 2 에 해당하는 부분
resource "aws_db_subnet_group" "private-subnet-group" {
  name       = "philoberry-private-subnet-group-${var.service_type}"
  subnet_ids = var.private_subnets

  tags = {
    Name    = "philoberry-private-subnet-group-${var.service_type}"
    Service = "philoberry-${var.service_type}"
  }
}

#RDS 
resource "aws_db_instance" "rds" {
  identifier           = "philoberry-db-${var.service_type}"         //DB 인스턴스 식별자
  db_subnet_group_name = aws_db_subnet_group.private-subnet-group.id //서브넷 그룹
  # snapshot_identifier    = data.aws_db_snapshot.db_snapshot.id         // 최신 스냅샷 식별자
  engine                 = "mysql"                        //엔진 유형
  engine_version         = "8.0.34"                       //MySQL 버전
  instance_class         = var.instance_class             //DB 인스턴스 클래스
  username               = var.username                   //마스터 사용자 이름
  password               = var.rds_password               //마스터 암호                 
  allocated_storage      = 20                             //할당된 스토리지
  max_allocated_storage  = 1000                           //최대 스토리지 임계값
  publicly_accessible    = var.publicly_accessible        //퍼블릭액세스 가능
  vpc_security_group_ids = [aws_security_group.rds_sg.id] //기본 VPC 보안 그룹  
  availability_zone      = "ap-northeast-2a"              //가용 영역
  port                   = 3306
  #backup_retention_period = 30
  #backup_window           = "01:00-03:00"
  parameter_group_name = "default.mysql8.0" //DB 파라미터 그룹                           //데이터베이스 포트
  skip_final_snapshot  = true               // ==> 나중에는 true
  # final_snapshot_identifier = "philoberry-db-${var.service_type}"
  # lifecycle {
  #   prevent_destroy = true,
  #   ignore_changes = [
  #   "snapshot_identifier",
  # ]
  # }
  tags = {
    Name    = "philoberry-rds-db-${var.service_type}"
    Service = "philoberry-${var.service_type}"
  }
}
