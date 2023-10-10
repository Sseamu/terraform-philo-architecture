data "aws_route53_zone" "front" {
  name         = var.domain
  private_zone = false
}
resource "aws_route53_record" "front" {
  zone_id = data.aws_route53_zone.front.zone_id
  name    = var.domain
  type    = "A"
  alias {
    name                   = var.alb_dns_name
    zone_id                = var.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "cert_validation" {
  name    = tolist(aws_acm_certificate.acm.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.acm.domain_validation_options)[0].resource_record_type
  zone_id = data.aws_route53_zone.front.zone_id
  records = [tolist(aws_acm_certificate.acm.domain_validation_options)[0].resource_record_value]
  ttl     = 60
  lifecycle {
    create_before_destroy = true
  }
}
//해당 도메인에 접근시  loadbalaner로 이동하도록 a레코드 설정
