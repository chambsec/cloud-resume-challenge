terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# ── DYNAMODB TABLE ──
resource "aws_dynamodb_table" "visitor_counter" {
  name         = "visitor-counter"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Project = "Cloud Resume Challenge"
  }
}

# ── IAM ROLE FOR LAMBDA ──
resource "aws_iam_role" "lambda_role" {
  path = "/service-role/"
  name = "visitor-counter-role-6f0er18k"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# ── IAM POLICY — LAMBDA CAN READ/WRITE DYNAMODB ──
resource "aws_iam_role_policy" "lambda_dynamodb_policy" {
  name = "lambda-dynamodb-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem"
      ]
      Resource = aws_dynamodb_table.visitor_counter.arn
    }]
  })
}

# ── IAM POLICY — LAMBDA CAN WRITE CLOUDWATCH LOGS ──
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# ── LAMBDA FUNCTION ──
resource "aws_lambda_function" "visitor_counter" {
  filename         = "lambda.zip"
  function_name    = "visitor-counter"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = filebase64sha256("lambda.zip")

  tags = {
    Project = "Cloud Resume Challenge"
  }
}

# ── API GATEWAY ──
resource "aws_apigatewayv2_api" "visitor_api" {
  name          = "visitor-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["https://www.chamb.dev"]
    allow_methods = ["GET", "OPTIONS"]
    allow_headers = ["Content-Type"]
  }
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id             = aws_apigatewayv2_api.visitor_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.visitor_counter.invoke_arn
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "count_route" {
  api_id    = aws_apigatewayv2_api.visitor_api.id
  route_key = "GET /count"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.visitor_api.id
  name        = "$default"
  auto_deploy = true
}

# ── ALLOW API GATEWAY TO INVOKE LAMBDA ──
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.visitor_counter.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.visitor_api.execution_arn}/*/*"
}

# ── OUTPUTS ──
output "api_endpoint" {
  value       = aws_apigatewayv2_api.visitor_api.api_endpoint
  description = "Your API Gateway URL"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.visitor_counter.name
  description = "DynamoDB table name"
}
