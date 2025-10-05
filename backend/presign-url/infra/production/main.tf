terraform {
  required_version = ">= 1.9.0"
  backend "s3" {
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "eu-west-3"
}


variable "bucket_name" {
  description = "The name of the bucket to browse"
}

# id -> data.terraform_remote_state.api_gateway.outputs.api_gateway_name
module "presign-lambda" {
  source = "../../../infra/lambda-module"
  lambda_name = "${var.bucket_name}-presign-url"
  lambda_file_full_path = "../../bootstrap"
  executable_file = "pre-sign-program"
  bucket_name = var.bucket_name
  lambda_env_variables = {
    "BUCKET" = var.bucket_name
  }
}


output "lambda_function_name" {
  value = module.presign-lambda.lambda_function_name
}

output "lambda_invoke_arn" {
  value = module.presign-lambda.lambda_invoke_arn
}