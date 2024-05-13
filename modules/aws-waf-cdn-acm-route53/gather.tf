data "aws_route53_zone" "zone" {
  name         = var.domain-name
  private_zone = false
}

data "aws_acm_certificate" "cert" {
  
  domain = var.domain-name
}

data "aws_s3_bucket" "s3-id" {
  bucket = var.s3-name
}