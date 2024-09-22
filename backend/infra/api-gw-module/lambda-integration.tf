data "aws_lambda_function" "lambda" {
  for_each      = { for lambda in var.lambdas : lambda.function_name => lambda }
  function_name =  each.value.function_name
}

resource "aws_api_gateway_resource" "lambda_resource" {
  for_each      = { for lambda in var.lambdas : lambda.endpoint_path => lambda }
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = each.value.endpoint_path
}

resource "aws_api_gateway_method" "lambda_method" {
  for_each      = { for lambda in var.lambdas : lambda.endpoint_path => lambda }
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.lambda_resource.id
  http_method   = each.value.http_method
  authorization = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "lambda_integration" {
  for_each    = { for lambda in var.lambdas : lambda.endpoint_path => lambda }
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.lambda_resource.id
  http_method             = aws_api_gateway_method.lambda_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = data.aws_lambda_function.lambda[each.value.function_name].arn
}

resource "aws_lambda_permission" "api_gateway_lambda" {
  for_each      = { for lambda in var.lambdas : lambda.function_name => lambda }
  statement_id  = "AllowAPIGatewayInvoke-${each.value.function_name}"
  action        = "lambda:InvokeFunction"
  function_name =  data.aws_lambda_function.lambda[each.key].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "prod"
  depends_on = [for method in aws_api_gateway_method.lambda_method : method]

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_api_gateway_base_path_mapping" "path_mapping" {
  api_id      = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_deployment.api_deployment.stage_name
  domain_name = var.domain_name
}


output "api_url" {
  value = { for lambda in var.lambdas : lambda.function_name => "${aws_api_gateway_deployment.api_deployment.invoke_url}/${lambda.endpoint_path}" }
}