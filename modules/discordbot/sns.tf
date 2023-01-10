###############################################################################
# SNS - IAM

# resource "aws_iam_role" "discordbot_sns_iam" {
#   name = "discordbot_sns_iam"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Sid    = "SnsAssume"
#         Principal = {
#           Service = "sns.amazonaws.com"
#         }
#       },
#     ]
#   })

#   inline_policy {
#     name = "discordbot_sns_iam"

#     policy = jsonencode({
#       Version = "2012-10-17"
#       Statement = [
#         {
#           Action = [
#             "logs:CreateLogGroup",
#             "logs:CreateLogStream",
#             "logs:PutLogEvents",
#             "logs:PutMetricFilter",
#             "logs:PutRetentionPolicy",
#           ]
#           Effect   = "Allow"
#           Resource = "*"
#         },
#         {
#           Effect   = "Allow"
#           # Principal = "*"
#           Action = [
#             "execute-api:Invoke"
#           ]
#           Resource = "*"
#         }
#       ]
#     })
#   }

#   # TODO
#   # tags = local.tags
# }

###############################################################################
# SNS configuration

resource "aws_sns_topic" "discordbot_sns_vh_topic" {
  name = "discordbot-vh-topic"
}

resource "aws_sns_topic_subscription" "sns_sub" {
  topic_arn = aws_sns_topic.discordbot_sns_vh_topic.arn
  protocol  = "lambda"
  endpoint  = module.lambda_bot_vh.lambda_function_arn
}
