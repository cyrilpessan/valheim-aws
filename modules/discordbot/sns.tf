###############################################################################
# SNS - IAM



###############################################################################
# SNS configuration

resource "aws_sns_topic" "discordbot_sns_vh_topic" {
  name = "discordbot-vh-topic"
}

