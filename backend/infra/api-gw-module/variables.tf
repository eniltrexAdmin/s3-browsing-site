locals {
  common_tags = tomap({
    "Terraform": "True"
  })

  full_domain_name = "${var.bucket_name}-s3-browsing-api.${var.domain_name}"
}

variable "bucket_name" {
  description = "The name of the bucket this project is going to browser, to identify the API GW name easily"
  type = string
}

variable "domain_certificate_arn" {
  description = "The ARN of the certificate of the domain where the API will point to"
  type=string
}

variable "domain_name" {
  description = "The domain name of the API GW"
  type=string
}

variable "route_53_id" {
  description = "The ID of the route53 where the domain is"
}

# API Key
variable "api_gw_key" {
  description = "The api key to make the call to BE, with the header x-api-key"
}


variable "lambdas" {
  description = "List of Lambda configurations"
  type = list(object({
    function_name = string  # Name of the Lambda function
    endpoint_path = string  # The API Gateway path for the Lambda
    http_method   = string  # The HTTP method (e.g., GET, POST)
  }))
}