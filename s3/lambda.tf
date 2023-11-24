# resource "aws_lambda_function" "s3_logs_to_cloudwatch" {
#   function_name = "s3LogsToCloudwatch"
#   handler       = "index.handler"
#   role          = aws_iam_role.lambda.arn
#   runtime       = "nodejs18.x"

#   filename         = "./s3/lambda_function_payload.zip"
#   source_code_hash = filebase64sha256("./s3/lambda_function_payload.zip")
#   vpc_config {
#     subnet_ids         = var.private_subnets
#     security_group_ids = [var.aws_endpoint_sg]
#   }
# }

# resource "aws_s3_bucket_notification" "bucket_notification" {
#   bucket = aws_s3_bucket.philoberry-s3.id

#   lambda_function {
#     lambda_function_arn = aws_lambda_function.s3_logs_to_cloudwatch.arn
#     events              = ["s3:ObjectCreated:*"]
#   }
# }

# resource "aws_lambda_permission" "allow_bucket" {
#   statement_id  = "AllowExecutionFromS3Bucket"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.s3_logs_to_cloudwatch.function_name
#   principal     = "s3.amazonaws.com"
#   source_arn    = aws_s3_bucket.philoberry-s3.arn
# }


# resource "aws_iam_role" "lambda" {
#   name = "lambda"

#   assume_role_policy = <<-EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": "sts:AssumeRole",
#       "Principal": {
#         "Service": "lambda.amazonaws.com"
#       },
#       "Effect": "Allow",
#       "Sid": ""
#     }
#   ]
# }
# EOF
# }

# resource "aws_iam_policy" "s3_policy" {
#   name        = "s3_policy"
#   description = "Policy for accessing specific S3 bucket"

#   policy = <<-EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Action": [
#         "s3:GetObject",
#         "s3:PutObject",
#         "s3:GetBucketNotification",
#         "s3:PutBucketNotification",
#         "lambda:InvokeFunction"
#       ],
#       "Resource": ["arn:aws:s3:::philoberry-s3-dev", "arn:aws:s3:::philoberry-s3-dev/*"]
#     },
#     {
#       "Effect": "Allow",
#       "Action": [
#         "ec2:CreateNetworkInterface",
#         "ec2:DescribeNetworkInterfaces",
#         "ec2:DeleteNetworkInterface",
#         "logs:CreateLogGroup",
#         "logs:CreateLogStream",
#         "logs:PutLogEvents"
#       ],
#       "Resource": "*"
#     }
#   ]
# }
# EOF
# }
