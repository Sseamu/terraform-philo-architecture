resource "aws_s3_bucket" "front_codepipeline_bucket" {
  bucket = "philoberry-cd-front-bucket"

  tags = {
    Name    = "philoberry-cd-frontend"
    Service = "philoberry-cd-frontend-${var.service_type}"
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_versioning" "front_cd_versioning" {
  bucket = aws_s3_bucket.front_codepipeline_bucket.id
  versioning_configuration {
    status = "Disabled" // after using "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "front-public-access" {
  bucket = aws_s3_bucket.front_codepipeline_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


# backend s3 pipeline

resource "aws_s3_bucket" "backend_codepipeline_bucket" {
  bucket = "philoberry-cd-backend-bucket"

  tags = {
    Name    = "philoberry-cd-backend"
    Service = "philoberry-cd-backend-${var.service_type}"
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_versioning" "backend_cd_versioning" {
  bucket = aws_s3_bucket.backend_codepipeline_bucket.id
  versioning_configuration {
    status = "Disabled" // after using "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "backend-public-access" {
  bucket = aws_s3_bucket.backend_codepipeline_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

