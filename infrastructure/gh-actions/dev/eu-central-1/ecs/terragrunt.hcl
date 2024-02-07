include "root" {
  path = find_in_parent_folders()
}

include "env" {
  path = "${get_terragrunt_dir()}/../../../../_env/ecs.hcl"
}

locals {
  # Automatically load account-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract the variables we need for easy access
  account_name   = local.account_vars.locals.account_name
  environment    = local.environment_vars.locals.environment
  aws_account_id = local.account_vars.locals.aws_account_id
  aws_region     = local.region_vars.locals.aws_region
}

inputs = {
  account_name   = local.account_name
  environment    = local.environment
  aws_account_id = local.aws_account_id
  aws_region     = local.aws_region
  certificate_arn         = dependency.acm.outputs.certificate_arn
  domain_name             = dependency.r53.outputs.domain_name
  ecs = {
    container_insights = "disabled"
    capacity_providers = {
      fargate = {}
      fargate_spot = {
        base   = 1
        weight = 1
      }
    }
    tasks = {
      app = {
        containers = {
          server = {
            command            = null
            cpu                = 128
            essential          = true
            image              = "164820026678.dkr.ecr.eu-central-1.amazonaws.com/gh-actions-app:init"
            logs_stream_prefix = "logs"
            memory             = 256
            memory_reservation = 128
            ports = [
              {
                container_port = 3000
                host_port      = 3000
                protocol      = "tcp"
                app_protocol = "http"
              }
            ]
            health_check = {
                command     = [
                    "CMD-SHELL",
                    "/usr/bin/curl 0:3000"
                ]
                interval    = 15
                retries     = 3
                start_period = 20
                timeout     = 2
            }
          }
        }
        cpu    = 512
        memory = 1024
      },
      gh-runner = {
        containers = {
          server = {
            command            = null
            cpu                = 128
            essential          = true
            image              = "164820026678.dkr.ecr.eu-central-1.amazonaws.com/gh-actions-gh-runner:latest"
            logs_stream_prefix = "logs"
            memory             = 256
            memory_reservation = 128
            ports = []
            health_check = {
                command     = [
                    "CMD-SHELL",
                    "exit 0"
                ]
                interval    = 15
                retries     = 3
                start_period = 20
                timeout     = 2
            }
          }
        }
        cpu    = 256
        memory = 512
      }
    }
    services_ext = {
      app = {
        deployment_maximum_percent         = 200
        deployment_minimum_healthy_percent = 100
        desired_count                      = 1
        min_count                          = 1
        max_count                          = 1
        scale_in_cooldown                  = 180
        scale_out_cooldown                 = 60
        priority                           = 1
        port                               = 3000
        protocol                           = "HTTP"
        capacity_provider                  = "FARGATE_SPOT"
        health_check                       = {
          enabled             = true
          healthy_threshold   = 2
          interval            = 10
          matcher             = 200
          path                = "/"
          port                = "traffic-port"
          protocol            = "HTTP"
          timeout             = 5
          unhealthy_threshold = 2
        }
      }
    }
    services_int = {
      gh-runner = {
        deployment_maximum_percent         = 200
        deployment_minimum_healthy_percent = 100
        desired_count                      = 1
        min_count                          = 1
        max_count                          = 1
        scale_in_cooldown                  = 180
        scale_out_cooldown                 = 60
        capacity_provider                  = "FARGATE_SPOT"
      }
    }

    services_bg_ext = {
      app = {
        deployment_maximum_percent         = 200
        deployment_minimum_healthy_percent = 100
        desired_count                      = 1
        min_count                          = 1
        max_count                          = 1
        scale_in_cooldown                  = 180
        scale_out_cooldown                 = 60
        priority                           = 11
        port                               = 3000
        protocol                           = "HTTP"
        capacity_provider                  = "FARGATE_SPOT"
        health_check                       = {
          enabled             = true
          healthy_threshold   = 2
          interval            = 10
          matcher             = 200
          path                = "/"
          port                = "traffic-port"
          protocol            = "HTTP"
          timeout             = 5
          unhealthy_threshold = 2
        }
      }
    }
    services_bg_int = {}
  }
  ecs_task_exec_role_arn = dependency.iam.outputs.ecs_task_exec_role_arn
  ecs_task_role_arn      = dependency.iam.outputs.ecs_task_role_arn
  codedeploy_role_arn    = dependency.iam.outputs.codedeploy_role_arn
  vpc_id                 = dependency.vpc.outputs.vpc_id
  vpc_subnets_web_ids    = dependency.vpc.outputs.vpc_subnets_web_ids
  vpc_subnets_app_ids    = dependency.vpc.outputs.vpc_subnets_app_ids
  retention_in_days      = 1
}
