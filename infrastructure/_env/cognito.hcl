terraform {
  source = "${get_terragrunt_dir()}/../../../../_modules//cognito"
}

dependency "r53" {
  config_path = "../../../common/global/r53"
}