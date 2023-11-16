resource "aws_acm_certificate" "acm" {
  domain_name               = "www.${var.domain}"
  subject_alternative_names = ["*.${var.domain}"]
  validation_method         = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}


# resource "aws_acm_certificate_validation" "certication_arn" {
#   certificate_arn         = aws_acm_certificate.acm.arn
#   validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]
#   depends_on              = [aws_acm_certificate.acm]
# }
resource "aws_acm_certificate_validation" "certication_arn" {
  certificate_arn         = aws_acm_certificate.acm.arn
  validation_record_fqdns = values({ for record in aws_route53_record.cert_validation : record.name => record.fqdn })
  depends_on              = [aws_route53_record.cert_validation]
}
