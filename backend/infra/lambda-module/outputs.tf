output "lambda_function_name" {
  value = aws_lambda_function.default.function_name
}

output "lambda_invoke_arn" {
  value = aws_lambda_function.default.invoke_arn
}