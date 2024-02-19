# --- S3 ---

resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "frontend-bucket-${var.aws_account_id}"
}

data "aws_iam_policy_document" "allow_access_from_cloud_front" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.frontend_bucket.arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values = [
        "${aws_cloudfront_distribution.cloud_front.arn}",
      ]
    }
  }
  version = "2008-10-17"
}

#Gives Cloud front access to the bucket
resource "aws_s3_bucket_policy" "frontend_bucket_policy" {
  bucket = aws_s3_bucket.frontend_bucket.id
  policy = data.aws_iam_policy_document.allow_access_from_cloud_front.json
}

resource "aws_cloudfront_origin_access_control" "frontend_bucket_oac" {
  name                              = "s3-cloudfront-oac"
  description                       = "Grant cloudfront access to s3 bucket ${aws_s3_bucket.frontend_bucket.id}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# --- CloudFront ---

locals {
  s3_origin_id = "S3Origin"
}

resource "aws_cloudfront_distribution" "cloud_front" {
  origin {
    domain_name              = aws_s3_bucket.frontend_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.frontend_bucket_oac.id
    origin_id                = local.s3_origin_id
  }

  enabled             = true
  comment             = "Learning Jenkins Frontend"
  default_root_object = "index.html"
  #Makes it so TF does not wait for CF to be fully deployed
  wait_for_deployment = false

  aliases = [local.jenkins_frontend_domain]
  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.jenkins_frontend.arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }

  is_ipv6_enabled = true
  http_version    = "http2and3"
  #Runns the CF only in EU an NA
  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 300
    max_ttl                = 3600
  }
}


# --- Outputs ---

output "cloud_front_domain_name" {
  value = aws_cloudfront_distribution.cloud_front.domain_name
}

output "frontend_bucket_name" {
  value = aws_s3_bucket.frontend_bucket.bucket
}
