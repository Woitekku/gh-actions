locals {
  ecs_services = merge(var.ecs.services_ext, var.ecs.services_int)
}