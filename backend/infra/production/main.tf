variable "bucket_name" {
      description = "The name of the S3 bucket to use"
      type        = string
}

variable "domain_name" {
      description = "The domain name of the API GW"
      type=string
}

variable "be_api_key" {
      description = "The api key to make the call to BE, with the header x-api-key"
      type = string
}

data "aws_acm_certificate" "default" {
      domain   = "*.${var.domain_name}"
      statuses = ["ISSUED"]
      provider = aws.aws-us-east
}

data "aws_route53_zone" "default" {
      name = var.domain_name
}


variable "list_lambda_state_bucket" {
      description = "The bucket where the list lambda  state is "
}

variable "list_lambda_state_key" {
      description = "tHe path where the API GW state is"
}

data "terraform_remote_state" "lambda_1_remote_state" {
      backend = "s3"

      config = {
            bucket         = var.list_lambda_state_bucket
            key            = var.list_lambda_state_key
            region         = "eu-west-3"
      }
}


module "default-api-gw"  {
      source = "../api-gw-module"
      bucket_name  = var.bucket_name
      domain_name = var.domain_name
      domain_certificate_arn = data.aws_acm_certificate.default.arn
      route_53_id  = data.aws_route53_zone.default.id
      api_gw_key = var.be_api_key
      lambdas = [{
            function_name = data.terraform_remote_state.lambda_1_remote_state.outputs.lambda_function_name
            endpoint_path = "list-s3"
            http_method   = "GET"
      },{}]
}

