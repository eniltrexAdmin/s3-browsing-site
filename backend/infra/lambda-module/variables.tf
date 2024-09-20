locals {
  common_tags = tomap({
    "Terraform": "True"
  })
}

variable "lambda-name" {
  description = "The name of the lambda"
  type        = string
  default     = "golang-skeleton"
}

variable "lambda_file_full_path" {
  description = "The relative full path from the directory where the terraform apply command is being executed."
  type = string
}

variable "executable-file" {
  description = "The name of the executable file. The output exec file when building the code."
  type = string
  default = "main"
}

variable "lambda-env-variables" {
  description = "Environment variables to pass to the lambda"
  type        = map(string)
  default     = {}
}

variable "aws_iam_role_iam_for_lambda_arn" {
  description = "The arn of the Role that has permissions to execute lambda"
}


variable "api_gateway_name" {
  description = "The gateway name form the GW module"
}

variable "endpoint_path" {
  description = "The endpoint to call"
  type = string
  default = "list-s3"
}

variable "domain_name" {
  description = "The domain name of the API GW"
  type=string
}

variable "aws_iam_group_deployers_name" {
  default = ""
}