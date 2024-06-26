resource "aws_cloudfront_origin_access_control" "origin-s3" {
  name                              = "origin-s3"
  description                       = "Example Policy"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "cdn-web-elb-distribution" {
  origin {
    domain_name = data.aws_s3_bucket.s3-id.bucket_regional_domain_name
    origin_id   = data.aws_s3_bucket.s3-id.id
    origin_access_control_id = aws_cloudfront_origin_access_control.origin-s3.id
    #custom_origin_config {
    #  http_port              = 80
    #  https_port             = 443
    #  origin_protocol_policy = "http-only"
    #  origin_ssl_protocols   = ["TLSv1.2"]
    #}
    

  }
  default_root_object = "index.html"
  
  aliases         = [var.domain-name, "*.${var.domain-name}", var.alb-domain]
  enabled         = true
  is_ipv6_enabled = true
  comment         = "CDN ALB Distribution"
  price_class     = "PriceClass_100"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = data.aws_s3_bucket.s3-id.id

    forwarded_values {
      query_string = false
      headers      = ["Host", "User-Agent", "Accept", "Accept-Encoding", "Accept-Language", "Referer"]
      cookies {
        forward = "none"
      }

    }
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
    cloudfront_default_certificate = true
  }

  web_acl_id = aws_wafv2_web_acl.web_acl.arn

  tags = merge(var.common-tags, {Name = var.cdn-name})

  ##depends_on = [aws_acm_certificate_validation.cert]
}