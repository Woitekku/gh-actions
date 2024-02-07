data "aws_availability_zones" "this" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"] // Only availability zones, without local zones.
  }
}

data "aws_ami" "amzn2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

data "aws_iam_policy_document" "ec2" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    effect = "Allow"
    principals {
      identifiers = [
        "ec2.amazonaws.com"
      ]
      type = "Service"
    }
  }
}

data "aws_iam_policy_document" "modify_nat_attribute" {
  statement {
    actions = [
      "ec2:ModifyInstanceAttribute",
      "ec2:CreateRoute",
      "ec2:ReplaceRoute",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeSubnets",
      "ec2:DescribeRouteTables",
      "ec2:DescribeAddresses",
      "ec2:AssociateAddress"
    ]
    effect = "Allow"
    resources = [
      "*"
    ]
  }
}