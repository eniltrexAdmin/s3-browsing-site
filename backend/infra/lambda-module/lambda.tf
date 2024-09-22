data "archive_file" "lambda" {
  type        = "zip"
  source_file = var.lambda_file_full_path
  output_path = "${var.executable_file}.zip"
}

resource "aws_lambda_function" "default" {
  description   =  var.lambda_name
  filename         = data.archive_file.lambda.output_path
  function_name = substr(var.lambda_name, 0, 64)
  handler       = var.executable_file
  publish       = true
  role          = aws_iam_role.lambda_role.arn
  runtime       = "provided.al2"
  timeout       = 6
  memory_size   = 128
  tags          = local.common_tags

  environment {
    variables = var.lambda_env_variables
  }
}


