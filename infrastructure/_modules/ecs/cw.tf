resource "aws_cloudwatch_log_group" "this" {
  name              =  format("%s-%s-ecs", var.account_name, var.environment)
  retention_in_days = var.retention_in_days

  tags = {
    Name = format("%s-%s-log", var.account_name, var.environment)
  }
}