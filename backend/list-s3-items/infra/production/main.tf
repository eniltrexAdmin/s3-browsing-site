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


variable "api_gw_state_bucket" {
  description = "The bucket where the API gW state is "
}

variable "api_gw_state_key" {
  description = "tHe path where the API GW state is"
}

data "terraform_remote_state" "api_gateway" {
  backend = "s3"

  config = {
    bucket         = var.api_gw_state_bucket
    key            = var.api_gw_state_key
    region         = "eu-west-3"
  }
}

data "aws_iam_group" "deployers" {
  group_name = "deployers"
}

data "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda_backend"
}


# id -> data.terraform_remote_state.api_gateway.outputs.api_gateway_name
module "s3-list-lambda" {
  source = "../../../infra/lambda-module"
  api_gateway_name = data.terraform_remote_state.api_gateway.outputs.api_gateway_name
  aws_iam_role_iam_for_lambda_arn = data.aws_iam_role.iam_for_lambda.arn
  aws_iam_group_deployers_name = data.aws_iam_group.deployers.group_name
  domain_name = data.terraform_remote_state.api_gateway.outputs.api_gw_domain_name

  lambda_file_full_path = "../../../list-s3-program"
}
