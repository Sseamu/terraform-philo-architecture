resource "aws_s3_bucket" "log_storage" {
  bucket = var.bucket_logs

  tags = {
    Name    = "philoberry-log_stroages-${var.service_type}"
    Service = "philoberry-log_stroages-${var.service_type}"
  }
}

resource "aws_s3_bucket_public_access_block" "log_storage_public-access" {
  bucket = aws_s3_bucket.log_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudwatch_log_group" "service" {
  name = "awslogs-all-${var.service_type}"

  tags = {
    Environment = var.service_type
    Application = var.application_name
  }
}

resource "aws_cloudwatch_log_metric_filter" "philoberry_error_filter" {
  name           = "philoberry_error_filter"
  pattern        = "[ERROR]"
  log_group_name = aws_cloudwatch_log_group.service.name

  metric_transformation {
    name      = "EventCount"
    namespace = "philoberry_contianer_errorlog"
    value     = "1"
  }
}
## cloudwatch alarm metric this skill is using for reduce live logs
resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "cpu_exceed_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "70"
  alarm_description   = "This metric checks cpu utilization"
  alarm_actions       = [aws_sns_topic.cpu_sns_topic.arn]
}



data "aws_iam_policy_document" "allow-lb" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["logdelivery.elb.amazonaws.com"]
    }

    actions = ["s3:PutObject"]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.log_storage.bucket}/awslogs-all-${var.service_type}/AWSLogs/${var.account_id}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"

      values = [
        "bucket-owner-full-control"
      ]
    }
  }
  statement {
    principals {
      type        = "Service"
      identifiers = ["logdelivery.elasticloadbalancing.amazonaws.com"]
    }

    actions = ["s3:PutObject"]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.log_storage.bucket}/awslogs-all-${var.service_type}/AWSLogs/${var.account_id}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"

      values = [
        "bucket-owner-full-cSontrol"
      ]
    }
  }
  statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.elb_account_id}:root"]
    }

    actions = ["s3:PutObject"]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.log_storage.bucket}/awslogs-all-${var.service_type}/AWSLogs/${var.account_id}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"

      values = [
        "bucket-owner-full-control"
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "allow-lb" {
  bucket = aws_s3_bucket.log_storage.id
  policy = data.aws_iam_policy_document.allow-lb.json
}

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  bucket = aws_s3_bucket.log_storage.id

  rule {
    id     = "log_lifecycle_${var.service_type}"
    status = "Enabled"

    expiration {
      days = 10
    }
  }
}
