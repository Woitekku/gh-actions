resource "aws_codedeploy_app" "this" {
  for_each         = local.ecs_services_bg
  compute_platform = "ECS"
  name             = format("%s-%s-app", var.account_name, var.environment)
}

resource "aws_codedeploy_deployment_group" "this" {
  for_each               = local.ecs_services_bg
  app_name               = aws_codedeploy_app.this[each.key].name
  deployment_group_name  = format("%s-%s-app", var.account_name, var.environment)
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  service_role_arn       = var.codedeploy_role_arn

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 1
    }
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.this.name
    service_name = aws_ecs_service.bluegreen[each.key].name
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }
  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.https[0].arn]
      }

      target_group {
        name = aws_lb_target_group.blue[each.key].name
      }

      target_group {
        name = aws_lb_target_group.green[each.key].name
      }
    }
  }
}