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

variable "lambda-file-full-path" {
  description = "The relative full path from the directory where the terraform apply command is being executed."
  type = string
  default = "../modules/go-project-lambda/dummy-go.zip"
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