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


resource "aws_iam_policy" "codepipeline_s3_access" {
  name        = "CodePipelineS3Access"
  description = "Allows CodePipeline to access S3 bucket"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::philoberry-cd-front-bucket/*",
        "arn:aws:s3:::philoberry-cd-front-bucket",
        "arn:aws:s3:::philoberry-cd-backend-bucket/*",
        "arn:aws:s3:::philoberry-cd-backend-bucket"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "codepipeline_s3_access" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_s3_access.arn
}
