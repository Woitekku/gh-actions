locals {
  ecs_services    = merge(var.ecs.services_ext, var.ecs.services_int)
  ecs_services_bg = merge(var.ecs.services_bg_ext, var.ecs.services_bg_int)
}