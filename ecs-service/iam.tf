// 향후 각각 파일에 있는 iam.tf를 한곳의 iam디렉토리에 만들어서 관리 => 재사용성 및 편의성 개선 

locals {
  ecs_task_inline_policy = {
    philoberry-ecs = {
      actions = [
        "ecs:RegisterTaskDefinition",
        "ecs:DescribeTaskDefinition",
        "ecs:DescribeContainerInstances",
        "ecs:DescribeTasks",
        "ecs:DeregisterTaskDefinition",
        "ecs:ListClusters",
        "ecs:RunTask",
        "ecs:StopTask"
      ]
      resources = [
        "*"
      ]
    }
    philoberry-iam = {
      actions = [
        "iam:PassRole",
        "iam:GetRole"
      ]
      resources = [
        "*"
      ]
    }
    philoberry-cloudmap = {
      actions = [
        "servicediscovery:*"
      ]
      resources = [
        "*"
      ]
    }
  }
}


resource "aws_iam_role" "philoberry_ecs_task" {
  name = "philoberry_ecs_task"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  dynamic "inline_policy" {
    for_each = local.ecs_task_inline_policy

    content {
      name = inline_policy.key

      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Action   = inline_policy.value.actions
            Effect   = "Allow"
            Resource = inline_policy.value.resources
          }
        ]
      })
    }
  }

  tags = {
    Name = "philoberry ecs task role"
  }

  lifecycle {
    create_before_destroy = true
  }
}







// ecs-service의 main.tf에 있는 내용과 동일한 내용 
// 작업방식만 다른거임 => 상황에 따라서 적합한 코드 사용하는게 유리

# data "aws_iam_policy" "ecs_task_execution" {
#   arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
# }

# resource "aws_iam_role" "jenkins_ecs_task_execution" {
#   name = "jenkins_ecs_task_execution"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "ecs-tasks.amazonaws.com"
#         }
#       }
#     ]
#   })

#   managed_policy_arns = [
#     data.aws_iam_policy.ecs_task_execution.arn
#   ]

#   tags = {
#     Name = "Jenkins ECS Task Execution Role"
#   }

#   lifecycle {
#     create_before_destroy = true
#   }
# }
