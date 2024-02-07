#{
#    "Location": "https://route53.amazonaws.com/2013-04-01/delegationset/N0911554IJ45DBUPDHBV",
#    "DelegationSet": {
#        "Id": "/delegationset/N0911554IJ45DBUPDHBV",
#        "CallerReference": "crunchy-gems",
#        "NameServers": [
#            "ns-124.awsdns-15.com",
#            "ns-1936.awsdns-50.co.uk",
#            "ns-1400.awsdns-47.org",
#            "ns-965.awsdns-56.net"
#        ]
#    }
#}

resource "aws_route53_zone" "this" {
  name              = var.domain_name
  delegation_set_id = var.delegation_set_id
  comment           = format("%s-%s", var.account_name, var.environment)

  tags = {
    Name        = format("%s-%s", var.account_name, var.environment)
  }
}