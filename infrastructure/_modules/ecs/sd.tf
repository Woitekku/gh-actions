resource "aws_service_discovery_http_namespace" "this" {
  name        = format("%s-%s.local", var.account_name, var.environment)
  description = format("%s-%s", var.account_name, var.environment)
}