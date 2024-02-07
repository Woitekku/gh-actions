locals {
  cloud_init_parts_nat = [
    {
      filepath     = "userdata_config.tpl"
      content-type = "text/cloud-config"
      vars         = {}
    },
    {
      filepath     = "userdata_script_nat.tpl"
      content-type = "text/x-shellscript"
      vars         = {
        ACCOUNTNAME = var.account_name
        ENVIRONMENT = var.environment
      }
    }
  ]

  cloud_init_parts_rendered_nat = [
    for part in local.cloud_init_parts_nat : <<EOF
--MIMEBOUNDARY
Content-Transfer-Encoding: 7bit
Content-Type: ${part.content-type}
Mime-Version: 1.0

${templatefile(part.filepath, part.vars)}
    EOF
  ]

  cloud_init_nat = base64encode(templatefile("cloud_init.tpl", {
    cloud_init_parts = local.cloud_init_parts_rendered_nat
  }))
}