resource "aws_cognito_user_pool" "this" {
  admin_create_user_config {
    allow_admin_create_user_only = true
  }
  name = format("%s-%s", var.account_name, var.environment)
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
    Name        = format("%s-%s", var.account_name, var.environment)
  }
}

resource "aws_cognito_user_pool_client" "this" {
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["openid"]
  access_token_validity                = 60
  callback_urls                        = [format("https://%s/oauth2/idpresponse", var.domain_name)]
  default_redirect_uri                 = format("https://%s/oauth2/idpresponse", var.domain_name)
  generate_secret                      = true
  id_token_validity                    = 60
  name                                 = "loadbalancer"
  read_attributes                      = ["name"]
  supported_identity_providers         = ["COGNITO"]
  user_pool_id                         = aws_cognito_user_pool.this.id
  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }
}

resource "aws_cognito_user_pool_domain" "this" {
  domain       = format("%s-%s", var.account_name, var.environment)
  user_pool_id = aws_cognito_user_pool.this.id
}