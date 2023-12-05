resource "aws_efs_file_system" "philberryt-efs" {
  creation_token = "my-philobery_efs"
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = {
    Name = "my-philobery_efs"
  }
}

resource "aws_efs_mount_target" "philoberry" {

  # for_each       = { for id in var.aws_private_subnets : id => id }
  # subnet_id      = each.key # or each.value, they are the same in this case. 문자열속성
  count          = length(var.aws_private_subnets)
  file_system_id = aws_efs_file_system.philberryt-efs.id
  subnet_id      = var.aws_private_subnets[count.index]
  security_groups = [
    var.philoberry_efs_sg_id
  ]
}


resource "aws_efs_access_point" "philoberry" {
  file_system_id = aws_efs_file_system.philberryt-efs.id

  posix_user {
    uid = 1000
    gid = 1000
  }
  root_directory {
    path = "/jenkins-philoberry-home"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "0755"
    }
  }
  tags = {
    Name = "jenkins-philoberry EFS Access Point"
  }
} //EFS 파일 시스템에 접근할 수 있는 access 포인트
