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