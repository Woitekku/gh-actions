resource "aws_iam_role" "nat" {
  assume_role_policy = data.aws_iam_policy_document.ec2.json
  name               = format("%s-%s", var.account_name, var.environment)
}

resource "aws_iam_instance_profile" "nat" {
  name = format("%s-%s", var.account_name, var.environment)
  role = aws_iam_role.nat.name
}

resource "aws_iam_role_policy_attachment" "nat_ssm" {
  role       = aws_iam_role.nat.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy" "modify_nat_attribute" {
  name   = format("%s-%s-modify-nat-ec2-attribute", var.account_name, var.environment)
  policy = data.aws_iam_policy_document.modify_nat_attribute.json
}

resource "aws_iam_role_policy_attachment" "modify_nat_attribute" {
  role       = aws_iam_role.nat.name
  policy_arn = aws_iam_policy.modify_nat_attribute.arn
}