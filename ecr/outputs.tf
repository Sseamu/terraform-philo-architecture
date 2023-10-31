output "aws_ecr_front_repository" {
  value = aws_ecr_repository.repo.repository_url
}
output "aws_ecr_nginx_repository" {
  value = aws_ecr_repository.repo2.repository_url
}
output "aws_ecr_express_repository" {
  value = aws_ecr_repository.repo3.repository_url
}