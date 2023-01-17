###############################################################################
# SNS configuration

resource "aws_sns_topic" "vhserver" {
  name = "discordbot-vh-topic"
}

resource "aws_sns_topic_subscription" "vhserver" {
  topic_arn = aws_sns_topic.vhserver.arn
  protocol  = "lambda"
  endpoint  = module.lambda_vhserver.lambda_function_arn
}
