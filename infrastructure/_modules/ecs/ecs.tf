resource "aws_ecs_cluster" "this" {
  configuration {
    execute_command_configuration {
      logging = "DEFAULT"
    }
  }
  name = format("%s-%s", var.account_name, var.environment)
  service_connect_defaults {
    namespace = aws_service_discovery_http_namespace.this.arn
  }
  setting {
    name  = "containerInsights"
    value = var.ecs.container_insights
  }

  tags = {
    Name        = format("%s-%s", var.account_name, var.environment)
  }
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
  cluster_name = aws_ecs_cluster.this.name

  dynamic "default_capacity_provider_strategy" {
    for_each = var.environment == "prd" ? [1] : []
    content {
      capacity_provider = "FARGATE"
      base = var.ecs.capacity_providers.fargate.base
      weight = var.ecs.capacity_providers.fargate.weight
    }
  }

  dynamic "default_capacity_provider_strategy" {
    for_each = var.environment != "prd" ? [1] : []
    content {
      capacity_provider = "FARGATE_SPOT"
      base = var.ecs.capacity_providers.fargate_spot.base
      weight = var.ecs.capacity_providers.fargate_spot.weight
    }
  }
}
resource "aws_ecs_task_definition" "this" {
  depends_on = [aws_secretsmanager_secret.this]
  for_each = var.ecs.tasks
  container_definitions = templatefile("task.tpl", {
    account        = var.aws_account_id
    awslogs-group  = aws_cloudwatch_log_group.this.name
    containers     = each.value.containers
    task_name      = each.key
    environment    = var.environment
    project        = var.account_name
    region         = var.aws_region
    secrets        = data.aws_secretsmanager_secret_version.this[each.key]
  })
  cpu                      = each.value.cpu
  execution_role_arn       = var.ecs_task_exec_role_arn
  family                   = format("%s-%s-%s", var.account_name, var.environment, each.key)
  memory                   = each.value.memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  runtime_platform {
    operating_system_family = "LINUX"
  }
  task_role_arn =  var.ecs_task_role_arn

  tags = {
    Name        = format("%s-%s", var.account_name, var.environment)
  }
}

resource "aws_ecs_service" "this" {
  for_each = local.ecs_services

  dynamic "capacity_provider_strategy" {
    for_each = var.environment == "prd" ? [1] : []
    content {
      capacity_provider = "FARGATE"
      base = var.ecs.capacity_providers.fargate.base
      weight = var.ecs.capacity_providers.fargate.weight
    }
  }

  dynamic "capacity_provider_strategy" {
    for_each = var.environment == "prd" ? [1] : []
    content {
      capacity_provider = "FARGATE_SPOT"
      weight = var.ecs.capacity_providers.fargate_spot.weight
    }
  }

  dynamic "capacity_provider_strategy" {
    for_each = var.environment != "prd" ? [1] : []
    content {
      capacity_provider = "FARGATE_SPOT"
      base = var.ecs.capacity_providers.fargate_spot.base
      weight = var.ecs.capacity_providers.fargate_spot.weight
    }
  }
  cluster                            = aws_ecs_cluster.this.id
  deployment_maximum_percent         = each.value.deployment_maximum_percent
  deployment_minimum_healthy_percent = each.value.deployment_minimum_healthy_percent
  desired_count                      = each.value.desired_count
  enable_execute_command             = true
  dynamic "load_balancer" {
    for_each = can(each.value.health_check) ? [1] : []
    content {
      target_group_arn = aws_lb_target_group.this[each.key]["arn"]
      container_name   = "server"
      container_port   = var.ecs.tasks[each.key]["containers"]["server"]["ports"][0]["container_port"]
    }
  }
  name = format("%s-%s-%s", var.account_name, var.environment, each.key)
  network_configuration {
    assign_public_ip = false
    security_groups  = [aws_security_group.ecs.id]
    subnets          = var.vpc_subnets_app_ids
  }
  platform_version    = "LATEST"
  scheduling_strategy = "REPLICA"
  service_connect_configuration {
    enabled = true
    namespace = aws_service_discovery_http_namespace.this.arn
    service {
      port_name = each.key
      client_alias {
        port = var.ecs.tasks[each.key]["containers"]["server"]["ports"][0]["container_port"]
      }
    }
    log_configuration {
      log_driver = "awslogs"
      options = {
        awslogs-group = aws_cloudwatch_log_group.this.name
        awslogs-region = var.aws_region
        awslogs-stream-prefix = format("envoy/%s", each.key)
      }
    }
  }
  task_definition = aws_ecs_task_definition.this[each.key]["arn"]

  lifecycle {
    ignore_changes = [task_definition]
  }

  tags = {
    Name        = format("%s-%s", var.account_name, var.environment)
  }
}