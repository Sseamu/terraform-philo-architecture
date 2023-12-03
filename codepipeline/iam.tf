resource "aws_iam_role" "codepipeline_role" {
  name = "my-codepipeline-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "codepipeline.amazonaws.com"
        },
        Effect = "Allow",
      },
    ]
  })
}
