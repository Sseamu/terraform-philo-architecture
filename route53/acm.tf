resource "aws_acm_certificate" "acm" {
  domain_name       = var.domain
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_acm_certificate_validation" "certication_arn" {
  certificate_arn         = aws_acm_certificate.acm.arn
  validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]
}
