resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "${var.name}-${var.environment}-dynamo"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "id"
  
  attribute {
    name = "id"
    type = "S"
  }
  tags = {
    Product = var.name
    Environment = var.environment
  }
}
