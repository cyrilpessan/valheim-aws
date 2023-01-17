###############################################################################
# IAM

# Base API Gateway role
resource "aws_iam_role" "api" {
  name = "discordbot-API"
  path = local.iam_path
  description = "API Gateway role for the Discord Bot"

  assume_role_policy = <<-EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Effect": "Allow",
      "Principal": {
          "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
  EOF
}

# Grants permission to log through cloudwatch
resource "aws_iam_role_policy_attachment" "cloudwatchlogs" {
  role       = aws_iam_role.api.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

# Grants permissions to invoke Lambda functions
resource "aws_iam_role_policy_attachment" "invoke_lambda" {
  role       = aws_iam_role.api.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaRole"
}

# Define the API Gateway settings to allow loggin and monitoring
resource "aws_api_gateway_account" "this" {
  cloudwatch_role_arn = aws_iam_role.api.arn
}

# Allow invoking Lambda from this API Gateway instance
resource "aws_api_gateway_rest_api_policy" "event" {
  rest_api_id = aws_api_gateway_rest_api.this.id

    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "execute-api:Invoke",
      "Resource": "${aws_api_gateway_rest_api.this.execution_arn}/*/*/*"
    }
  ]
}
EOF
}

###############################################################################
# REST API

resource "aws_api_gateway_rest_api" "this" {
  name = "discord-bot-api"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "event" {
  path_part   = "event"
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.this.id
}

###############################################################################
# POST

resource "aws_api_gateway_request_validator" "event_post" {
  name                        = "discord-bot-api-validator-event-post"
  rest_api_id                 = aws_api_gateway_rest_api.this.id
  validate_request_body       = true
  validate_request_parameters = true
}

resource "aws_api_gateway_method" "event_post" {
  rest_api_id      = aws_api_gateway_rest_api.this.id
  resource_id      = aws_api_gateway_resource.event.id
  api_key_required = false
  http_method      = "POST"
  authorization    = "NONE"

  request_validator_id = aws_api_gateway_request_validator.event_post.id

  depends_on = [
    aws_api_gateway_request_validator.event_post
  ]
}

resource "aws_api_gateway_integration" "event_post" {
  http_method             = aws_api_gateway_method.event_post.http_method
  resource_id             = aws_api_gateway_resource.event.id
  rest_api_id             = aws_api_gateway_rest_api.this.id
  type                    = "AWS"
  integration_http_method = aws_api_gateway_method.event_post.http_method
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

  uri = module.lambda_interaction.lambda_function_invoke_arn

  credentials = aws_iam_role.api.arn
}

resource "aws_api_gateway_method_response" "event_post_200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.event.id
  http_method = aws_api_gateway_method.event_post.http_method
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

resource "aws_api_gateway_integration_response" "event_post_200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.event.id
  http_method = aws_api_gateway_method.event_post.http_method
  status_code = aws_api_gateway_method_response.event_post_200.status_code 

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
    aws_api_gateway_integration.event_post
  ]
}

resource "aws_api_gateway_method_response" "event_post_401" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.event.id
  http_method = aws_api_gateway_method.event_post.http_method
  status_code = "401"
}

resource "aws_api_gateway_integration_response" "event_post_401" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.event.id
  http_method = aws_api_gateway_method.event_post.http_method
  status_code = aws_api_gateway_method_response.event_post_401.status_code 

  selection_pattern = ".*[UNAUTHORIZED].*"
  response_templates = {
    "application/json" = "invalid request signature"
  }

  depends_on = [
    aws_api_gateway_integration.event_post
  ]
}

###############################################################################
# OPTIONS - CORS

# OPTIONS HTTP method.
resource "aws_api_gateway_method" "event_options" {
  rest_api_id      = aws_api_gateway_rest_api.this.id
  resource_id      = aws_api_gateway_resource.event.id
  http_method      = "OPTIONS"
  authorization    = "NONE"
  api_key_required = false
}

# OPTIONS method response.
resource "aws_api_gateway_method_response" "event_options" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.event.id
  http_method = aws_api_gateway_method.event_options.http_method
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
resource "aws_api_gateway_integration" "event_options" {
  rest_api_id          = aws_api_gateway_rest_api.this.id
  resource_id          = aws_api_gateway_resource.event.id
  http_method          = aws_api_gateway_method.event_options.http_method
  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"
  request_templates = {
    "application/json" : "{\"statusCode\": 200}"
  }

  depends_on = [aws_api_gateway_method.event_options]
}

# OPTIONS integration response.
resource "aws_api_gateway_integration_response" "event_options" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.event.id
  http_method = aws_api_gateway_integration.event_options.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

###############################################################################
# deployment

resource "aws_api_gateway_deployment" "event" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.this.body))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration_response.event_post_401,
    aws_api_gateway_integration_response.event_options,
  ]
}

resource "aws_api_gateway_stage" "event" {
  deployment_id = aws_api_gateway_deployment.event.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = var.stage
}
