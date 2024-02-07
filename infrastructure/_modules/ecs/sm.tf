resource "aws_secretsmanager_secret" "this" {
  for_each = var.ecs.tasks
  name = format("%s/%s/%s", var.account_name, var.environment, each.key)

    tags = {
    Name = format("%s-%s-%s", var.account_name, var.environment, each.key)
  }
}

resource "aws_secretsmanager_secret_version" "this" {
  for_each = var.ecs.tasks
  secret_id     = aws_secretsmanager_secret.this[each.key].id
  secret_string = jsonencode({key1="value1"})
}