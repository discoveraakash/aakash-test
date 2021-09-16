resource "aws_cloudfront_distribution" "api_gateway" {
  origin {
    domain_name = "${var.api_domain}.${var.main_domain}"
    #origin_path = "/${var.environment}"
    origin_id   = "api"

    custom_origin_config {
			http_port              = 80
			https_port             = 443
			origin_protocol_policy = "https-only"
			origin_ssl_protocols   = ["TLSv1","TLSv1.1"]
    }
  }

  enabled             = true

  aliases = ["${var.cdn_domain}.${var.main_domain}"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "api"

    forwarded_values {
      query_string = true
			headers = ["Accept", "Referer", "Authorization", "Content-Type"]
			cookies {
				forward = "all"
			}
    }
		compress = true
		viewer_protocol_policy = "https-only"
  }

  price_class = "PriceClass_All"

  viewer_certificate {
		acm_certificate_arn      = var.api_certificate_arn
		minimum_protocol_version = "TLSv1.1_2016"
		ssl_support_method       = "sni-only"
  }

	restrictions {
		geo_restriction {
			restriction_type = "none"
		}
	}
}

resource "aws_route53_record" "api_cf_route_53_record" {
  name = var.cdn_domain
  type = "A"
  zone_id = var.zone_id

  alias {
    name                   = "${aws_cloudfront_distribution.api_gateway.domain_name}"
    zone_id                = aws_cloudfront_distribution.api_gateway.hosted_zone_id
    evaluate_target_health = false
  }
}