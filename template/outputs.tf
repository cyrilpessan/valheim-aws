###############################################################################
# vhserver

# output "monitoring_url" {
#   value       = module.vhserver.monitoring_url
#   description = "URL to monitor the Valheim Server"
# }

# output "bucket_id" {
#   value       = module.vhserver.bucket_id
#   description = "The S3 bucket name"
# }

# output "instance_id" {
#   value       = module.vhserver.instance_id
#   description = "The EC2 instance ID"
# }

###############################################################################
# discord bot

output "rest_api_id" {
  description = "REST API id"
  value       = module.discordbot.rest_api_id
}

output "deployment_id" {
  description = "Deployment id"
  value       = module.discordbot.deployment_id
}

output "deployment_invoke_url" {
  description = "Deployment invoke url"
  value       = module.discordbot.deployment_invoke_url
}

output "deployment_execution_arn" {
  description = "Deployment execution ARN"
  value       = module.discordbot.deployment_execution_arn
}

output "rest_execution_arn" {
  description = "REST API execution ARN"
  value       = module.discordbot.rest_execution_arn
}

# output "url" {
#   description = "Serverless invoke url"
#   value       = local.url
# }

output "name" {
  description = "API Gateway name"
  value       = module.discordbot.name
}

output "lambda_function_invoke_arn" {
  description = "lambda_function_invoke_arn"
  value       = module.discordbot.lambda_function_invoke_arn
}