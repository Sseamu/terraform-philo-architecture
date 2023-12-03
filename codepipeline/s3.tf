resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "my-codepipeline-bucket"
  acl    = "private"

  versioning {
    enabled = false
  }

  lifecycle {
    prevent_destroy = false
  }
}
