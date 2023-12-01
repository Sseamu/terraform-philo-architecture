resource "aws_s3_bucket" "philoberry-s3" {
  bucket = var.bucket //버킷이름
  tags = {
    Name    = "philoberry-img-${var.service_type}"
    Service = "philoberry-${var.service_type}"
  }
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_public_access_block" "public-access" {
  bucket = aws_s3_bucket.philoberry-s3.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "bucket-policy" {
  bucket = aws_s3_bucket.philoberry-s3.id

  policy = <<-POLICY
{
  "Version": "2012-10-17",
  "Id": "Policy1694490590860",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::666897452748:user/junhyeok-front",
          "arn:aws:iam::666897452748:root",
          "arn:aws:iam::666897452748:role/philoberry_ecs_task",
          "arn:aws:iam::666897452748:user/hansom-server"
        ]
      },
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": ["${aws_s3_bucket.philoberry-s3.arn}/*"]
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::666897452748:user/junhyeok-front",
          "arn:aws:iam::666897452748:user/hansom-server",
          "arn:aws:iam::666897452748:role/philoberry_ecs_task",
          "arn:aws:iam::666897452748:root"
        ]
      },
      "Action": "s3:ListBucket",
      "Resource": ["${aws_s3_bucket.philoberry-s3.arn}"]
    },
    {
      "Sid": "rds_all_permission",
      "Effect": "Allow",
      "Principal": {
        "Service": "rds.amazonaws.com"
      },
      "Action": "s3:GetObject",
      "Resource": ["${aws_s3_bucket.philoberry-s3.arn}/*"]
    }
  ]
}
POLICY
}

resource "aws_s3_bucket_cors_configuration" "philoberry-s3" {
  bucket = aws_s3_bucket.philoberry-s3.id

  cors_rule {
    allowed_headers = ["*"] // 모든 헤더 허용
    allowed_methods = ["GET", "PUT", "POST"]
    allowed_origins = ["https://philoberry.com", "https://www.philoberry.com"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}


//정적 웹 호스팅
# resource "aws_s3_bucket_website_configuration" "philoberry-s3" {
#   bucket = aws_s3_bucket.philoberry-s3.id

#   index_document {
#     suffix = "index.html"
#   }

#   error_document {
#     key = "error.html"
#   }

#   routing_rule {
#     condition {
#       key_prefix_equals = "docs/"
#     }
#     redirect {
#       replace_key_prefix_with = "documents/"
#     }
#   }
# }
