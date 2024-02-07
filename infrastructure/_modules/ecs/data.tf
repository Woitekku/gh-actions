data "aws_availability_zones" "this" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"] // Only availability zones, without local zones.
  }
}

data "aws_secretsmanager_secret_version" "this" {
  depends_on = [aws_secretsmanager_secret.this, aws_secretsmanager_secret_version.this]
  for_each = var.ecs.tasks
  secret_id = aws_secretsmanager_secret.this[each.key].id
}

data "aws_route53_zone" "this" {
  name = var.domain_name
}