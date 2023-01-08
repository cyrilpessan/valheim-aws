###############################################################################
# IAM

resource "aws_iam_role" "discord_bot_api" {
  name = "discord_bot_api-iam"

  assume_role_policy = <<-EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
  EOF
}

# TODO attach policy: arn:aws:iam::aws:policy/service-role/AWSLambdaRole

resource "aws_iam_role_policy_attachment" "discord_bot_api-cloudwatchlogs" {
  role       = aws_iam_role.discord_bot_api.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_iam_role_policy_attachment" "discord_bot_api-lambda" {
  role       = aws_iam_role.discord_bot_api.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaRole"
}

resource "aws_api_gateway_account" "api_gateway_account" {
  cloudwatch_role_arn = aws_iam_role.discord_bot_api.arn
}

resource "aws_api_gateway_rest_api_policy" "discord_bot_api" {
  rest_api_id = aws_api_gateway_rest_api.discord_bot_api.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "execute-api:Invoke",
      "Resource": "execute-api:/*/*/*"
    }
  ]
}
EOF
}

###############################################################################
# REST API

resource "aws_api_gateway_rest_api" "discord_bot_api" {
  name = "discord-bot-api"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "discord_bot_api" {
  path_part   = "event"
  parent_id   = aws_api_gateway_rest_api.discord_bot_api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.discord_bot_api.id
}

###############################################################################
# POST

resource "aws_api_gateway_request_validator" "discord_bot_api" {
  name                        = "discord-bot-api-validator"
  rest_api_id                 = aws_api_gateway_rest_api.discord_bot_api.id
  validate_request_body       = true
  validate_request_parameters = true
}

resource "aws_api_gateway_method" "discord_bot_api" {
  rest_api_id      = aws_api_gateway_rest_api.discord_bot_api.id
  resource_id      = aws_api_gateway_resource.discord_bot_api.id
  api_key_required = false
  http_method      = "POST"
  authorization    = "NONE"

  request_validator_id = aws_api_gateway_request_validator.discord_bot_api.id

  depends_on = [
    aws_api_gateway_request_validator.discord_bot_api
  ]
}

resource "aws_api_gateway_integration" "discord_bot_api" {
  http_method             = aws_api_gateway_method.discord_bot_api.http_method
  resource_id             = aws_api_gateway_resource.discord_bot_api.id
  rest_api_id             = aws_api_gateway_rest_api.discord_bot_api.id
  type                    = "AWS"
  integration_http_method = aws_api_gateway_method.discord_bot_api.http_method
  passthrough_behavior    = "NEVER"

  request_templates = {
    "application/json" = <<EOT
{
  "timestamp": "$input.params('x-signature-timestamp')",
  "signature": "$input.params('x-signature-ed25519')",
  "jsonBody" : $input.json('$')
}
EOT
  }

  uri = module.lambda_bot_interaction.lambda_function_invoke_arn

  credentials = aws_iam_role.discord_bot_api.arn
}

resource "aws_api_gateway_method_response" "discord_bot_api_200" {
  rest_api_id = aws_api_gateway_rest_api.discord_bot_api.id
  resource_id = aws_api_gateway_resource.discord_bot_api.id
  http_method = aws_api_gateway_method.discord_bot_api.http_method
  status_code = "200"
  response_models = {
     "application/json" = "Empty"
  }

  /**
   * This is where the configuration for CORS enabling starts.
   * We need to enable those response parameters and in the 
   * integration response we will map those to actual values
   */
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true,
    "method.response.header.Access-Control-Allow-Methods"     = true,
    "method.response.header.Access-Control-Allow-Origin"      = true,
    "method.response.header.Access-Control-Allow-Credentials" = true
  }

}

resource "aws_api_gateway_integration_response" "discord_bot_api_200" {
  rest_api_id = aws_api_gateway_rest_api.discord_bot_api.id
  resource_id = aws_api_gateway_resource.discord_bot_api.id
  http_method = aws_api_gateway_method.discord_bot_api.http_method
  status_code = aws_api_gateway_method_response.discord_bot_api_200.status_code 

  /**
   * This is second half of the CORS configuration.
   * Here we give values to each of the header parameters to ALLOW 
   * Cross-Origin requests from ALL hosts.
   **/
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods"     = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"      = "'*'",
    "method.response.header.Access-Control-Allow-Credentials" = "'true'"
  }

  depends_on = [
    aws_api_gateway_integration.discord_bot_api
  ]
}

resource "aws_api_gateway_method_response" "discord_bot_api_401" {
  rest_api_id = aws_api_gateway_rest_api.discord_bot_api.id
  resource_id = aws_api_gateway_resource.discord_bot_api.id
  http_method = aws_api_gateway_method.discord_bot_api.http_method
  status_code = "401"
}

resource "aws_api_gateway_integration_response" "discord_bot_api_401" {
  rest_api_id = aws_api_gateway_rest_api.discord_bot_api.id
  resource_id = aws_api_gateway_resource.discord_bot_api.id
  http_method = aws_api_gateway_method.discord_bot_api.http_method
  status_code = aws_api_gateway_method_response.discord_bot_api_401.status_code 

  selection_pattern = ".*[UNAUTHORIZED].*"
  response_templates = {
    "application/json" = "invalid request signature"
  }

  depends_on = [
    aws_api_gateway_integration.discord_bot_api
  ]
}

###############################################################################
# OPTIONS - CORS

# OPTIONS HTTP method.
resource "aws_api_gateway_method" "options" {
  rest_api_id      = aws_api_gateway_rest_api.discord_bot_api.id
  resource_id      = aws_api_gateway_resource.discord_bot_api.id
  http_method      = "OPTIONS"
  authorization    = "NONE"
  api_key_required = false
}

# OPTIONS method response.
resource "aws_api_gateway_method_response" "options" {
  rest_api_id = aws_api_gateway_rest_api.discord_bot_api.id
  resource_id = aws_api_gateway_resource.discord_bot_api.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

# OPTIONS integration.
resource "aws_api_gateway_integration" "options" {
  rest_api_id          = aws_api_gateway_rest_api.discord_bot_api.id
  resource_id          = aws_api_gateway_resource.discord_bot_api.id
  http_method          = aws_api_gateway_method.options.http_method
  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"
  request_templates = {
    "application/json" : "{\"statusCode\": 200}"
  }

  depends_on = [aws_api_gateway_method.options]
}

# OPTIONS integration response.
resource "aws_api_gateway_integration_response" "options" {
  rest_api_id = aws_api_gateway_rest_api.discord_bot_api.id
  resource_id = aws_api_gateway_resource.discord_bot_api.id
  http_method = aws_api_gateway_integration.options.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

###############################################################################
# deployment

resource "aws_api_gateway_deployment" "discord_bot_api" {
  rest_api_id = aws_api_gateway_rest_api.discord_bot_api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.discord_bot_api.body))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration_response.discord_bot_api_401,
    aws_api_gateway_integration_response.options,
  ]
}

resource "aws_api_gateway_stage" "discord_bot_api" {
  deployment_id = aws_api_gateway_deployment.discord_bot_api.id
  rest_api_id   = aws_api_gateway_rest_api.discord_bot_api.id
  stage_name    = var.stage
}
