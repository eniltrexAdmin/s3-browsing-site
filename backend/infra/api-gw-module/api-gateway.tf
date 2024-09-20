resource "aws_api_gateway_rest_api" "api" {
  name        = "${var.bucket_name} s3 browsing api"
  description = "API Gateway for ${var.bucket_name} Brwosing Lambdas"
}


resource "aws_api_gateway_domain_name" "custom_domain" {
  domain_name =  local.full_domain_name
  certificate_arn = var.domain_certificate_arn
}

resource "aws_route53_record" "api_domain" {
  zone_id = var.route_53_id
  name    = local.full_domain_name
  type    = "A"

  alias {
    name                   = aws_api_gateway_domain_name.custom_domain.cloudfront_domain_name
    zone_id                = aws_api_gateway_domain_name.custom_domain.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_api_gateway_api_key" "api_key" {
  name    = "Key for ${var.bucket_name} browsing site BE"
  value = var.api_gw_key
  enabled = true
}

# Usage Plan
resource "aws_api_gateway_usage_plan" "browsing_s3_usage_plan" {
  name = "Browsing ${var.bucket_name} site key"
  api_stages {
    api_id = aws_api_gateway_rest_api.api.id
    stage  = "prod"
  }
  throttle_settings {
    burst_limit = 100
    rate_limit  = 50
  }
}

# Usage Plan Key
resource "aws_api_gateway_usage_plan_key" "usage_plan_key" {
  key_id        = aws_api_gateway_api_key.api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.browsing_s3_usage_plan.id
}