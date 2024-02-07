# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

locals {
  # Automatically load account-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract the variables we need for easy access
  account_name      = local.account_vars.locals.account_name
  environment       = local.environment_vars.locals.environment
  aws_account_id    = local.account_vars.locals.aws_account_id
  aws_region        = local.region_vars.locals.aws_region
}

# Generate an AWS provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 5.32.1"
    }
  }
}

provider "aws" {
  region = "${local.aws_region}"

  # Only these AWS Account IDs may be operated on by this template
  allowed_account_ids = ["${local.aws_account_id}"]

 default_tags {
   tags = {
     Environment = "${local.environment}"
     Owner       = "gems"
     Project     = "${local.account_name}"
     Managed     = "terraform"
   }
 }
}

provider "aws" {
  alias = "us-east-1"
  region = "us-east-1"

  # Only these AWS Account IDs may be operated on by this template
  allowed_account_ids = ["${local.aws_account_id}"]

 default_tags {
   tags = {
     Environment = "${local.environment}"
     Owner       = "gems"
     Project     = "${local.account_name}"
     Managed     = "terraform"
   }
 }
}
EOF
}

# Configure Terragrunt to automatically store tfstate files in an S3 bucket
remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    encrypt        = true
    bucket         = "${get_env("TG_BUCKET_PREFIX", "")}terragrunt-states-${local.account_name}-${local.aws_account_id}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    dynamodb_table = "terraform-locks-${local.account_name}-${local.aws_account_id}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# GLOBAL PARAMETERS
# These variables apply to all configurations in this subfolder. These are automatically merged into the child
# `terragrunt.hcl` config via the include block.
# ---------------------------------------------------------------------------------------------------------------------

# Configure root level variables that all resources can inherit. This is especially helpful with multi-account configs
# where terraform_remote_state data sources are placed directly into the modules.
inputs = merge(
  local.account_vars.locals,
  local.region_vars.locals,
  local.environment_vars.locals,
)
