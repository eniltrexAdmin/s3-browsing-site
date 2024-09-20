
# Output the API Gateway ID so it can be used by other modules/resources
output "api_id" {
  value = aws_api_gateway_rest_api.api.id
}

# Output the root resource ID (the base path of the API)
output "root_resource_id" {
  value = aws_api_gateway_rest_api.api.root_resource_id
}

output "api_name" {
  value = aws_api_gateway_rest_api.api.name
}

output "domain_name" {
  value = var.domain_name
}