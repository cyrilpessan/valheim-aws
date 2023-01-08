###############################################################################
# lambda bot - iam

#########
# SNS

data "aws_iam_policy_document" "Lambda-SNS-Publish" {
  statement {
    effect = "Allow"
    actions   = ["sns:Publish", "sns:GetTopicAttributes", "sns:ListTopics"]
    # resources = ["*"]
    resources = [ aws_sns_topic.discordbot_sns_vh_topic.arn ]
  }
}

resource "aws_iam_policy" "Lambda-SNS-Publish" {
  name        = "Lambda-SNS-Publish"
  path        = var.discordbot_iam_path
  description = "Lambda-SNS-Publish"
  policy      = data.aws_iam_policy_document.Lambda-SNS-Publish.json
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

  attach_policies = true
  policies = [
    aws_iam_policy.Lambda-SNS-Publish.arn,
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
  number_of_policies = 2

  source_path = "${path.module}/lambda-bot-interaction"

  # store_on_s3 = true
  # s3_bucket   = "my-bucket-id-with-lambda-builds"

  layers = [
    module.lambda_bot_common_layer.lambda_layer_arn,
  ]

  environment_variables = {
    DISCORD_PUBLIC_KEY = var.discord_public_key
    SNS_PUBLISH_VH_ARN = aws_sns_topic.discordbot_sns_vh_topic.arn
  }

  allowed_triggers = {
    APIGatewayPost = {
      service    = "apigateway"
      source_arn = "${aws_api_gateway_deployment.discord_bot_api.execution_arn}*/POST/event"
    },
  }

  # Timeout in seconds. 
  # Discord allows only 3 seconds to receive the initial answer (can be a ACK)
  timeout = 3


  # tags = {
  #   Module = "lambda-with-layer"
  # }
}
