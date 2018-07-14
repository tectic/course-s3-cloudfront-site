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
  }
}

resource "aws_s3_bucket" "apex_bucket" {
  bucket = "${var.domain}"

  website {
    redirect_all_requests_to = "https://www.${var.domain}"
  }
}

# resource "aws_acm_certificate" "certificate" {
#   domain_name               = "www.${var.domain}"
#   subject_alternative_names = ["${var.domain}"]
#   validation_method         = "DNS"
# }


# resource "aws_cloudfront_origin_access_identity" "www_origin_access_identitiy" {}
# resource "aws_cloudfront_origin_access_identity" "apex_origin_access_identitiy" {}


# resource "aws_cloudfront_distribution" "www_distribution" {
#   aliases = ["www.${var.domain}"]


#   default_cache_behavior {
#     allowed_methods = ["GET", "HEAD"]
#     cached_methods  = ["GET", "HEAD"]
#     compress        = true


#     forwarded_values {
#       query_string = false


#       cookies {
#         forward = "none"
#       }
#     }


#     path_pattern           = "*"
#     target_origin_id       = "${aws_cloudfront_origin_access_identity.www_origin_access_identitiy.id}"
#     viewer_protocol_policy = "redirect-to-https"
#   }


#   default_root_object = "index.html"
#   enabled             = true


#   default_cache_behavior {
#     allowed_methods  = ["GET", "HEAD"]
#     cached_methods   = ["GET", "HEAD"]
#     compress         = true
#     path_pattern     = "*"
#     target_origin_id = "${aws_cloudfront_origin_access_identity.www_origin_access_identitiy.id}"


#     forwarded_values {
#       cookies {
#         forward      = "none"
#         query_string = false
#       }
#     }
#   }


#   origin {
#     domain_name = "${aws_s3_bucket.www_bucket.website_endpoint}.${aws_s3_bucket.www_bucket.website_domain}"
#     origin_id   = "S3-Website-${aws_s3_bucket.www_bucket.website_endpoint}.${aws_s3_bucket.www_bucket.website_domain}"


#     custom_origin_config {
#       http_port              = "80"
#       https_port             = "443"
#       origin_protocol_policy = "http-only"
#       origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
#     }
#   }


#   restrictions {
#     geo_restriction {
#       restriction_type = "none"
#     }
#   }


#   viewer_certificate {
#     acm_certificate_arn      = "${aws_acm_certificate.certificate.arn}"
#     minimum_protocol_version = "TLSv1_2016"
#     ssl_support_method       = "sni-only"
#   }
# }

