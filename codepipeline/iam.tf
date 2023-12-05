resource "aws_iam_role" "codepipeline_role" {
  name = "my-codepipeline-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = ["codedeploy.amazonaws.com", "codepipeline.amazonaws.com"]
        },
        Effect = "Allow",
      },
    ]
  })
}

resource "aws_iam_policy" "ecs_describe_services_policy" {
  name        = "ECSDescribeServicesPolicy"
  description = "Allows to describe ECS services"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "ecs:DescribeServices",
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "ecs_describe_services_policy_attachment" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.ecs_describe_services_policy.arn
}
