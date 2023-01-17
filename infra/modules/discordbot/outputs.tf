output "api_gateway_rest_api_name" {
  description = "API Gateway name"
  value       = aws_api_gateway_rest_api.this.name
}

output "discord_interactions_endpoint_url" {
  description = "INTERACTIONS ENDPOINT URL in the Discord Bot configuration"
  value       = "${aws_api_gateway_deployment.event.invoke_url}${var.stage}${aws_api_gateway_resource.event.path}"
}


# DEBUG
# output "server_instance_id" {
#   description = "The Instance ID (if any) that is currently fulfilling the Spot Instance request."
#   value = aws_spot_instance_request.ec2test.spot_instance_id
# }
