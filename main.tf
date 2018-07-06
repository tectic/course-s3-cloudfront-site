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
}
