terraform {
  source = "${get_terragrunt_dir()}/../../../../_modules//ecs"
}

dependency "iam" {
  config_path = "../../../common/global/iam"
}

dependency "r53" {
  config_path = "../../../common/global/r53"
}

dependency "acm" {
  config_path = "../acm"
}

dependency "vpc" {
  config_path = "../vpc"
}