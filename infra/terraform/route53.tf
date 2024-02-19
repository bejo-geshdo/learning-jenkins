resource "aws_route53_record" "jenkins_controller" {
  zone_id = var.route53_zone_id
  type    = "A"
  ttl     = "300"
  name    = var.domain
  records = [aws_eip.jenkins-controller.public_ip]
}

locals {
  jenkins_frontend_domain = "www.${var.domain}"
}

resource "aws_route53_record" "jenkins_frontend" {
  zone_id = var.route53_zone_id
  type    = "CNAME"
  ttl     = "300"
  name    = local.jenkins_frontend_domain
  records = [aws_cloudfront_distribution.cloud_front.domain_name]
}

# Create a certificate for the domain

resource "aws_acm_certificate" "jenkins_frontend" {
  provider          = aws.us_east_1
  domain_name       = local.jenkins_frontend_domain
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "jenkins_frontend_dns" {
  allow_overwrite = true
  name            = tolist(aws_acm_certificate.jenkins_frontend.domain_validation_options)[0].resource_record_name
  records         = [tolist(aws_acm_certificate.jenkins_frontend.domain_validation_options)[0].resource_record_value]
  type            = tolist(aws_acm_certificate.jenkins_frontend.domain_validation_options)[0].resource_record_type
  zone_id         = var.route53_zone_id
  ttl             = 60
}

#Added this to give the cert time to validate before adding it to Cloudfront
#TODO Find a better way to check if the cert has validate, if it's not validate terraform will get an error
resource "time_sleep" "jenkins_frontend_dns_cert_sleep" {
  depends_on = [aws_route53_record.jenkins_frontend_dns]

  create_duration = "60s"
}


