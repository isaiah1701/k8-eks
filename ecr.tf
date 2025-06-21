resource "aws_ecr_repository" "flask_app" {
  name = "flask-eks-docs" ## ECR repository name indicating its purpose
  
  tags = {
    Name = "flask-eks-docs" ## tag for visibility and good for team environment
    Owner = "isaiah4748"
  }
}

output "flask_ecr_url" {
  value = aws_ecr_repository.flask_app.repository_url ## output ECR URL 
}