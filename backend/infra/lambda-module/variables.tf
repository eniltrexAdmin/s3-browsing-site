locals {
  common_tags = tomap({
    "Terraform": "True"
  })
}

variable "lambda_name" {
  description = "The name of the lambda"
  type        = string
}

variable "lambda_file_full_path" {
  description = "The relative full path from the directory where the terraform apply command is being executed."
  type = string
}

variable "executable_file" {
  description = "The name of the executable file. The output exec file when building the code."
  type = string
}

variable "lambda_env_variables" {
  description = "Environment variables to pass to the lambda"
  type        = map(string)
}

variable "bucket_name" {
  description = "The bucket name where this lambda needs access to"
}