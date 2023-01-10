###############################################################################
# lambda bot - iam

#########
# SNS

data "aws_iam_policy_document" "Lambda_SNS_Subscribe" {
  statement {
    effect = "Allow"
    actions   = ["sns:Subscribe", "sns:GetTopicAttributes", "sns:ListTopics"]
    resources = [ aws_sns_topic.discordbot_sns_vh_topic.arn ]
  }
}

resource "aws_iam_policy" "Lambda_SNS_Subscribe" {
  name        = "Lambda_SNS_Subscribe"
  path        = var.discordbot_iam_path
  description = "Lambda_SNS_Subscribe"
  policy      = data.aws_iam_policy_document.Lambda_SNS_Subscribe.json
}

###############################################################################
# lambda bot - command

variable "lambda_bot_vh_name" { 
  type = string 
  default = "lambda-bot-vhserver"
}

locals {
  lambda_bot_vh_name = "${var.lambda_bot_vh_name}-${var.stage}"
}

module "lambda_bot_vh" {
  source = "terraform-aws-modules/lambda/aws"
  version = "4.7.1"

  function_name = local.lambda_bot_vh_name
  description   = "lambda-bot-vhserver"
  handler       = "${var.lambda_bot_vh_name}.lambda_handler"
  runtime       = "python3.9"
  publish       = true

  attach_policies = true
  policies = [
    aws_iam_policy.Lambda_SNS_Subscribe.arn,
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
  number_of_policies = 2

  source_path = "${path.module}/lambda-bot-vhserver"

  # store_on_s3 = true
  # s3_bucket   = "my-bucket-id-with-lambda-builds"

  layers = [
    module.lambda_bot_common_layer.lambda_layer_arn,
  ]

  environment_variables = {
    DISCORD_PUBLIC_KEY = var.discord_public_key
    DISCORD_AUTH_TOKEN = var.discord_auth_token
    DISCORD_APP_ID = var.discord_application_id
  }

  allowed_triggers = {
    SNSTopic = {
        service = "sns"
        source_arn = aws_sns_topic.discordbot_sns_vh_topic.arn
    }
  }

  

  # Timeout in seconds. 
  # Discord allows only 3 seconds to receive the initial answer (can be a ACK)
  timeout = 300


  # tags = {
  #   Module = "lambda-with-layer"
  # }
}

