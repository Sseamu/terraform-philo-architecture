#로드밸런서 주소 
output "alb_arn" {
  value = aws_lb.alb.arn
}

output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}

output "zone_id" {
  value = aws_lb.alb.zone_id
}

output "http_listener_arn" {
  value = aws_lb_listener.http_listener.arn
}

output "https_listener_arn" {
  value = aws_lb_listener.https_listener.arn
}

output "http_listener" {
  value = aws_lb_listener.http_listener
}

output "https_listener" {
  value = aws_lb_listener.https_listener
}

output "alb_sg_id" {
  value = aws_security_group.alb.id
}
