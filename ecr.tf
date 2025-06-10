resource "aws_ecr_repository" "flask_app" {
  name = "flask-eks-docs"
  
  tags = {
    Name = "flask-eks-docs"
    Owner = "isaiah4748"
  }
}

output "flask_ecr_url" {
  value = aws_ecr_repository.flask_app.repository_url
}