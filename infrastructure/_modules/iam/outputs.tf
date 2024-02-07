output "ecs_task_exec_role_arn" {
  value = aws_iam_role.ecs_task_exec.arn
}

output "ecs_task_role_arn" {
  value = aws_iam_role.ecs_task.arn
}

output "codedeploy_role_arn" {
  value = aws_iam_role.codedeploy.arn
}