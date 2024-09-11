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
    name                   = aws_api_gateway_domain_name.custom_domain.domain_name
    zone_id                = aws_api_gateway_domain_name.custom_domain.regional_zone_id
    evaluate_target_health = false
  }
}