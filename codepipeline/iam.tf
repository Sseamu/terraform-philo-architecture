resource "aws_iam_role" "codepipeline_role" {
  name = "my-codepipeline-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = ["codedeploy.amazonaws.com", "codepipeline.amazonaws.com", "codebuild.amazonaws.com"]
        },
        Effect = "Allow",
      },
    ]
  })
}

resource "aws_iam_policy" "codepipeline_permissions" {
  name        = "CodePipelinePermissions"
  description = "Permissions for CodePipeline"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = ["ecs:DescribeServices", "codebuild:StartBuild", "codebuild:BatchGetBuilds", "logs:CreateLogStream", "logs:CreateLogGroup"],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codepipeline_permissions_attach" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_permissions.arn
}

resource "aws_iam_policy" "logs_createloggroup_policy" {
  name        = "LogsCreateLogGroupPolicy"
  description = "Allows to create CloudWatch Logs log groups"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "logs:CreateLogGroup",
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codepipeline_role_createloggroup_attach" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.logs_createloggroup_policy.arn
}

resource "aws_iam_policy" "codedeploy_full_access_policy" {
  name        = "CodeDeployFullAccessPolicy"
  description = "Provides full access to CodeDeploy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "codedeploy:*",
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "elb_full_access_policy" {
  name        = "ELBFullAccessPolicy"
  description = "Provides full access to Elastic Load Balancer"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "elasticloadbalancing:*",
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codepipeline_role_elb_full_access_attach" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.elb_full_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "codepipeline_role_codedeploy_full_access_attach" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codedeploy_full_access_policy.arn
}



resource "aws_iam_policy" "ecs_full_access_policy" {
  name        = "ECSFullAccessPolicy"
  description = "Provides full access to ECS"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "ecs:*",
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codepipeline_role_ecs_full_access_attach" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.ecs_full_access_policy.arn
}


resource "aws_iam_policy" "passrole_policy" {
  name        = "PassRolePolicy"
  description = "Allows to pass a role to ECS"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "iam:PassRole",
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codepipeline_role_passrole_attach" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.passrole_policy.arn
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
