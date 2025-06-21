resource "aws_dynamodb_table" "terraform_locks" {
  name           = "terraform-state-locks"     ##dynanodb table name stating its purpose 
  billing_mode   = "PAY_PER_REQUEST"          ## only   pay for what you use 
  hash_key       = "LockID"                 ### primary key for the table

  attribute {
    name = "LockID"  ## defines lock id as string type 
    type = "S"
  }

  tags = {
    Name        = "terraform-state-locks"  ## tags to improve resource management
    Environment = "shared"
    ManagedBy   = "terraform"
  }
}