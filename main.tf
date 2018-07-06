variable "domain" {}
variable "region" {}

provider "aws" {
  region = "${var.region}"
}

resource "aws_s3_bucket" "www_bucket" {
  bucket = "www.${var.domain}"
}
