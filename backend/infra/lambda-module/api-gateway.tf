data "aws_api_gateway_rest_api" "existing_api" {
  name = var.api_gateway_name
}

resource "aws_api_gateway_resource" "lambda_resource" {
  rest_api_id = data.aws_api_gateway_rest_api.existing_api.id
  parent_id   = data.aws_api_gateway_rest_api.existing_api.root_resource_id
  path_part   = var.endpoint_path
}

resource "aws_api_gateway_method" "lambda_method" {
  rest_api_id   = data.aws_api_gateway_rest_api.existing_api.id
  resource_id   = aws_api_gateway_resource.lambda_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = data.aws_api_gateway_rest_api.existing_api.id
  resource_id             = aws_api_gateway_resource.lambda_resource.id
  http_method             = aws_api_gateway_method.lambda_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.default.invoke_arn
}

resource "aws_lambda_permission" "api_gateway_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.default.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${data.aws_api_gateway_rest_api.existing_api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = data.aws_api_gateway_rest_api.existing_api.id
  stage_name  = "prod"

  # Make sure the deployment happens after the new methods and resources are created
  depends_on = [
    aws_api_gateway_method.lambda_method,
    aws_api_gateway_integration.lambda_integration
  ]

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_api_gateway_base_path_mapping" "path_mapping" {
  api_id      = data.aws_api_gateway_rest_api.existing_api.id
  stage_name  = aws_api_gateway_deployment.api_deployment.stage_name
  domain_name = var.domain_name
}


output "api_url" {
  value = "${aws_api_gateway_deployment.api_deployment.invoke_url}/${var.endpoint_path}"
}