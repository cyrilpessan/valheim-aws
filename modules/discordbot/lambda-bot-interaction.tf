###############################################################################
# lambda bot - iam

resource "aws_iam_role" "lambda_bot_interaction_role" {
  name = "serverless_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_bot_interaction_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

###############################################################################
# lambda bot - interaction

variable "lambda_bot_interaction_name" { 
  type = string 
  default = "lambda-bot-interaction"
}

locals {
  lambda_bot_interaction_name = "${var.lambda_bot_interaction_name}-${var.stage}"
}

module "lambda_bot_interaction" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = local.lambda_bot_interaction_name
  description   = "lambda-bot-interaction"
  handler       = "${var.lambda_bot_interaction_name}.lambda_handler"
  runtime       = "python3.9"
  publish       = true

  attach_policy = true
  policy = aws_iam_role_policy_attachment.lambda_policy.policy_arn
  # policy = aws_iam_role_policy.lambda_policy.id

  source_path = "${path.module}/lambda-bot-interaction"

  # store_on_s3 = true
  # s3_bucket   = "my-bucket-id-with-lambda-builds"

  layers = [
    module.lambda_bot_common_layer.lambda_layer_arn,
  ]

  environment_variables = {
    DISCORD_PUBLIC_KEY = var.discord_public_key
    # DISCORD_AUTH_TOKEN = var.discord_auth_token
    # COMMAND_LAMBDA_ARN = aws_lambda_function.lambda_bot_command.arn
  }

  allowed_triggers = {
    APIGatewayPost = {
      service    = "apigateway"
      source_arn = "${aws_api_gateway_deployment.discord_bot_api.execution_arn}*/POST/event"
    },
  }

  ######################
  # Lambda Function URL
  ######################
  create_lambda_function_url = true
  authorization_type         = "AWS_IAM"
  cors = {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["*"]
    allow_headers     = ["date", "keep-alive"]
    expose_headers    = ["keep-alive", "date"]
    max_age           = 86400
  }

  timeout = 3

  lambda_role = aws_iam_role.lambda_bot_interaction_role.arn

  # tags = {
  #   Module = "lambda-with-layer"
  # }
}
