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

#Needed because the certificates to be used for cloudfront must be on us-east-1 region.
provider "aws" {
  alias   = "aws-us-east"
  region  = "us-east-1"
}

