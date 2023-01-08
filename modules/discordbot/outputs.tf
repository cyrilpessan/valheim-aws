output "rest_api_id" {
  description = "REST API id"
  value       = aws_api_gateway_rest_api.discord_bot_api.id
}

output "deployment_id" {
  description = "Deployment id"
  value       = aws_api_gateway_deployment.discord_bot_api.id
}

output "deployment_invoke_url" {
  description = "Deployment invoke url"
  value       = aws_api_gateway_deployment.discord_bot_api.invoke_url
}

output "deployment_execution_arn" {
  description = "Deployment execution ARN"
  value       = aws_api_gateway_deployment.discord_bot_api.execution_arn
}

output "rest_execution_arn" {
  description = "REST API execution ARN"
  value       = aws_api_gateway_rest_api.discord_bot_api.execution_arn
}

# output "url" {
#   description = "Serverless invoke url"
#   value       = local.url
# }

output "name" {
  description = "API Gateway name"
  value       = aws_api_gateway_rest_api.discord_bot_api.name
}

output "lambda_function_invoke_arn" {
  description = "lambda_function_invoke_arn"
  value       = module.lambda_bot_interaction.lambda_function_invoke_arn
}

