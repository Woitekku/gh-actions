resource "aws_iam_role" "ecs_task" {
  assume_role_policy = data.aws_iam_policy_document.assume_role_ecs_task.json
  name               = format("%s-ecs-task", var.account_name)

  tags = {
    Name = format("%s-ecs-task", var.account_name)
  }
}

resource "aws_iam_role" "ecs_task_exec" {
  assume_role_policy = data.aws_iam_policy_document.assume_role_ecs_task.json
  name               = format("%s-ecs-task-exec", var.account_name)

  tags = {
    Name = format("%s-ecs-task-exec", var.account_name)
  }
}

resource "aws_iam_policy" "ecs_task_custom" {
  name   = format("%s-ecs-task", var.account_name)
  policy = data.aws_iam_policy_document.ecs_task.json

  tags = {
    Name = format("%s-ecs-task", var.account_name)
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_custom" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = aws_iam_policy.ecs_task_custom.arn
}

resource "aws_iam_policy" "ecs_task_exec_custom" {
  name   = format("%s-ecs-task-exec", var.account_name)
  policy = data.aws_iam_policy_document.ecs_task_exec.json

  tags = {
    Name = format("%s-ecs-task-exec", var.account_name)
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec_custom" {
  role       = aws_iam_role.ecs_task_exec.name
  policy_arn = aws_iam_policy.ecs_task_exec_custom.arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec" {
  role       = aws_iam_role.ecs_task_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "codedeploy" {
  name               = format("%s-codedeploy", var.account_name)
  assume_role_policy = data.aws_iam_policy_document.assume_role_codedeploy.json

  tags = {
    Name = format("%s-%s-codedeploy", var.account_name, terraform.workspace)
  }
}

resource "aws_iam_policy" "codedeploy" {
  name   = format("%s-codedeploy", var.account_name)
  policy = data.aws_iam_policy_document.codedeploy.json

  tags = {
    Name = format("%s-%s-codedeploy", var.account_name, terraform.workspace)
  }
}

resource "aws_iam_role_policy_attachment" "codedeploy" {
  role       = aws_iam_role.codedeploy.name
  policy_arn = aws_iam_policy.codedeploy.arn
}