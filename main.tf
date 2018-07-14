variable "domain" {}
variable "referer" {}
variable "region" {}

provider "aws" {
  region = "${var.region}"
}

resource "aws_s3_bucket" "www_bucket" {
  bucket = "www.${var.domain}"

  policy = <<HERE
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::www.${var.domain}/*",
            "Condition": {
                "StringLike": {
                    "aws:Referer": "${var.referer}"
                }
            }
        }
    ]
}
HERE

  website {
    index_document = "index.html"
    error_document = "404.html"
  }
}

resource "aws_s3_bucket" "apex_bucket" {
  bucket = "${var.domain}"

  website {
    redirect_all_requests_to = "https://www.${var.domain}"
  }
}

resource "aws_cloudfront_origin_access_identity" "www_origin_access_identitiy" {}
resource "aws_cloudfront_origin_access_identity" "apex_origin_access_identitiy" {}

resource "aws_cloudfront_distribution" "www_distribution" {
  aliases = ["www.${domain}"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    compress         = true
    path_pattern     = "*"
    target_origin_id = "${www_origin_access_identitiy.id}"

    forwarded_values {
      cookies {
        forward      = "none"
        query_string = false
      }
    }
  }

  default_root_object = "index.html"
  enabled             = true

  restrictions {
    restriction_type = "none"
  }

  origin {
    custom_origin_config {
      http_port  = "80"
      https_port = "443"
    }
  }
}
