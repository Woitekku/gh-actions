/*
resource "aws_cognito_user_pool" "this" {
  for_each = terraform.workspace == "staging" ? toset([terraform.workspace]) : toset([])
  admin_create_user_config {
    allow_admin_create_user_only = true
  }
  name = format("%s-%s-cognito", var.project, terraform.workspace)
  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "name"
    required                 = true
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }

  tags = {
    Name        = format("%s-%s-cognito", var.project, terraform.workspace)
    Project     = var.project
    Environment = terraform.workspace
    Terraform   = true
  }
}

resource "aws_cognito_user_pool_client" "this" {
  for_each                             = terraform.workspace == "staging" ? toset([terraform.workspace]) : toset([])
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["openid"]
  access_token_validity                = 60
  callback_urls                        = [format("https://%s/oauth2/idpresponse", var.r53.front)]
  default_redirect_uri                 = format("https://%s/oauth2/idpresponse", var.r53.front)
  generate_secret                      = true
  id_token_validity                    = 60
  name                                 = "loadbalancer"
  read_attributes                      = ["name"]
  supported_identity_providers         = ["COGNITO"]
  user_pool_id                         = aws_cognito_user_pool.this[each.value].id
  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }
}

resource "aws_cognito_user_pool_domain" "this" {
  for_each     = terraform.workspace == "staging" ? toset([terraform.workspace]) : toset([])
  domain       = format("%s-%s", var.project, terraform.workspace)
  user_pool_id = aws_cognito_user_pool.this[each.value].id
}
*/