resource "aws_security_group" "nat" {
  description = "security group for nat ec2 instance"
  name        = format("%s-%s", var.account_name, var.environment)
  vpc_id      = aws_vpc.this.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "nat_any_any" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "allow to any over any"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.nat.id
  to_port           = -1
  type              = "egress"
}

resource "aws_security_group_rule" "nat_ingress_itself" {
  description       = "allow from any in the same security group"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.nat.id
  self              = true
  to_port           = 0
  type              = "ingress"
}

resource "aws_security_group_rule" "nat_ingress_vpc_any" {
  cidr_blocks       = [var.cidr_block]
  description       = "allow from vpc any over any"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.nat.id
  to_port           = -1
  type              = "ingress"
}