include "root" {
  path = find_in_parent_folders()
}

include "env" {
  path = "${get_terragrunt_dir()}/../../../../_env/ecr.hcl"
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
  repositories   = ["gh-runner", "app"]
}