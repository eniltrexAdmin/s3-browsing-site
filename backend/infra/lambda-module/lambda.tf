resource "aws_lambda_function" "default" {
  description   = "${var.lambda-name} Lambda"
  filename         = var.lambda_file_full_path
  function_name = substr(var.lambda-name, 0, 64)
  handler       = var.executable-file
  publish       = true
  role          = var.aws_iam_role_iam_for_lambda_arn
  runtime       = "go1.x"
  timeout       = 6
  memory_size   = 128
  tags          = local.common_tags

  environment {
    variables = var.lambda-env-variables
  }
}


