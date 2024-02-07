data "aws_kms_alias" "secretsmanager" {
  name = "alias/aws/secretsmanager"
}

data "aws_iam_policy_document" "assume_role_ecs_task" {
  statement {
    sid    = "ECSTask"
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type = "Service"
      identifiers = [
        "ecs-tasks.amazonaws.com"
      ]
    }
  }
}

data "aws_iam_policy_document" "ecs_task" {
  statement {
    sid    = "ECSTaskSSM"
    effect = "Allow"
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "ecs_task_exec" {
  statement {
    sid    = "ECSTaskExecutionSecretsManager"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
    ]
    resources = [format("arn:aws:secretsmanager:%s:%s:secret:%s/*/*", var.aws_region, var.aws_account_id, var.account_name)]
  }
  statement {
    sid    = "ECSTaskExecutionKMS"
    effect = "Allow"
    actions = [
      "kms:Decrypt"
    ]
    resources = [data.aws_kms_alias.secretsmanager.arn]
  }
}

data "aws_iam_policy_document" "assume_role_codedeploy" {
  statement {
    sid     = "CodeDeploy"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "codedeploy" {
  statement {
    sid    = "AllowLoadBalancingAndECSModifications"
    effect = "Allow"

    actions = [
      "ecs:CreateTaskSet",
      "ecs:DeleteTaskSet",
      "ecs:DescribeServices",
      "ecs:UpdateServicePrimaryTaskSet",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:ModifyRule"
    ]

    resources = ["*"]
  }
  statement {
    sid    = "AllowPassRole"
    effect = "Allow"

    actions = ["iam:PassRole"]

    resources = [
      format("arn:aws:iam::%s:role/%s-ecs-task", var.aws_account_id, var.account_name),
      format("arn:aws:iam::%s:role/%s-ecs-task-exec", var.aws_account_id, var.account_name)
    ]
  }

  statement {
    sid    = "DeployService"
    effect = "Allow"

    actions = [
      "codedeploy:GetDeploymentGroup",
      "codedeploy:CreateDeployment",
      "codedeploy:GetDeployment",
      "codedeploy:GetDeploymentConfig",
      "codedeploy:RegisterApplicationRevision"
    ]

    resources = ["*"]
  }
}
