terraform {
  required_version = ">= 1.9.0"
  backend "s3" {
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-3"
}



variable "bucket_name" {
  description = "The name of the S3 bucket to use"
  type        = string
}


variable "basic_auth_user" {
  default = "admin"
}

variable "basic_auth_pass" {
  description = "Password for basic auth"
  type        = string
  sensitive   = true
}

variable "be_api_key" {
  description = "The api key to make the call to BE, with the header x-api-key"
  type = string
}


# ──────────────────────────────────────────────
# S3 bucket for static site
# ──────────────────────────────────────────────

resource "aws_s3_bucket" "site" {
  bucket = "${var.bucket_name}-browser-site"
}

resource "aws_s3_bucket_ownership_controls" "site" {
  bucket = aws_s3_bucket.site.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "site" {
  bucket = aws_s3_bucket.site.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


# ──────────────────────────────────────────────
# Upload HTML files with injected API key
# ──────────────────────────────────────────────

locals {
  files = ["index.html", "viewer.html"]
}

resource "aws_s3_object" "site_files" {
  for_each = toset(local.files)
  bucket   = aws_s3_bucket.site.id
  key      = each.value
  content  = replace(file("${path.module}/../../${each.value}"), "__API_KEY__", var.be_api_key)
  content_type = "text/html"
}

# ──────────────────────────────────────────────
# Lambda@Edge function for Basic Auth
# ──────────────────────────────────────────────

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1" # Lambda@Edge must live here
}

resource "aws_iam_role" "edge_lambda_role" {
  name = "${var.bucket_name}-browsing-site-edge-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = [
            "lambda.amazonaws.com",
            "edgelambda.amazonaws.com"
          ]
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "edge_policy" {
  role       = aws_iam_role.edge_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "template_file" "basic_auth" {
  template = file("${path.module}/../lambda_edge/basic_auth.js")

  vars = {
    BASIC_USER = var.basic_auth_user
    BASIC_PASS = var.basic_auth_pass
  }
}

data "archive_file" "basic_auth_zip" {
  type        = "zip"
  output_path = "${path.module}/../lambda_edge/basic_auth.zip"

  source {
    content  = data.template_file.basic_auth.rendered
    filename = "basic_auth.js"
  }
}



resource "aws_lambda_function" "basic_auth" {
  provider         = aws.us_east_1
  function_name    = "${var.bucket_name}-basic-auth"
  role             = aws_iam_role.edge_lambda_role.arn
  handler          = "basic_auth.handler"
  runtime          = "nodejs18.x"
  filename         = data.archive_file.basic_auth_zip.output_path
  publish          = true

  source_code_hash = filebase64sha256(data.archive_file.basic_auth_zip.output_path)

  lifecycle {
    create_before_destroy = true
  }
}

# ──────────────────────────────────────────────
# CloudFront distribution
# ──────────────────────────────────────────────

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "${var.bucket_name}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "cdn" {
  enabled             = true
  default_root_object = "index.html"

  origin {
    domain_name              = aws_s3_bucket.site.bucket_regional_domain_name
    origin_id                = "s3-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  default_cache_behavior {
    target_origin_id       = "s3-origin"
    cache_policy_id         = aws_cloudfront_cache_policy.no_cache_html.id
    viewer_protocol_policy  = "redirect-to-https"
    allowed_methods         = ["GET", "HEAD"]
    cached_methods          = ["GET", "HEAD"]
    lambda_function_association {
      event_type   = "viewer-request"
      lambda_arn   = aws_lambda_function.basic_auth.qualified_arn
      include_body = false
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  retain_on_delete = false

  price_class = "PriceClass_100"
}

resource "aws_cloudfront_cache_policy" "no_cache_html" {
  name = "no-cache-html"
  parameters_in_cache_key_and_forwarded_to_origin {

    cookies_config {
      cookie_behavior = "none" # No cookies forwarded for HTML
    }

    headers_config {
      header_behavior = "none" # No headers forwarded for HTML
    }

    query_strings_config {
      query_string_behavior = "none" # No query strings forwarded
    }
  }

  default_ttl = 0
  max_ttl     = 0
  min_ttl     = 0
}

output "cloudfront_url" {
  value = aws_cloudfront_distribution.cdn.domain_name
}
