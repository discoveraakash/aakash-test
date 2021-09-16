resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_security_group" "lambda_sg" {
  name        = "${var.name}-${var.environment}-lambda-sg"
  description = "Allow kubernetes custer traffic only"
  vpc_id      = var.vpc_id
  tags = {
    Product     = var.name
    Environment = var.environment
  }
}

resource "aws_lambda_function" "aakash_lambda" {
  filename      = "lambda_function_payload.zip"
  function_name = "${var.name}-${var.environment}-lambda"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.lambda_handler"
  memory_size   = 512
  runtime       = "java11"

  vpc_config {
    subnet_ids         = concat(var.public_subnets.*.id, var.private_subnets.*.id)
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
  environment {
    variables = {
      foo = "bar"
    }
  }
  tags = {
    Product     = var.name
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "lambda_log" {
  name              = "/aws/lambda/${var.name}-${var.environment}-lambda"
  retention_in_days = 14
}


resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.aakash_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.apigateway_arn}/*/*/*"
}