output "zone_id" {
  value = aws_route53_zone.this.zone_id
}

output "domain_name" {
  value = var.domain_name
}