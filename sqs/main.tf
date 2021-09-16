resource "aws_sqs_queue" "aakash_queue" {
  name                        = "${var.name}-${var.environment}-sqs.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
  
  tags = {
    Product                   = var.name
    Environment               = var.environment
  }
}