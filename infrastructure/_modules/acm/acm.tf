resource "aws_acm_certificate" "this" {
  domain_name               = var.domain_name
  subject_alternative_names = [format("*.%s", var.domain_name)]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = format("%s-%s", var.account_name, var.environment)
  }
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for record in aws_route53_record.this : record.fqdn]

  depends_on = [aws_acm_certificate.this, aws_route53_record.this]
}