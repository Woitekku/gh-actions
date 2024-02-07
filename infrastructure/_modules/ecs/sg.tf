resource "aws_security_group" "lb" {
  description = "sg for lb"
  name        = format("%s-%s-lb", var.account_name, var.environment)
  vpc_id = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = format("%s-%s-lb", var.account_name, var.environment)
  }
}

resource "aws_security_group_rule" "lb_egress_any" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "egress any/any"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.lb.id
  to_port           = -1
  type              = "egress"
}

resource "aws_security_group_rule" "lb_itself_any" {
  description       = "itself"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.lb.id
  self              = true
  to_port           = 0
  type              = "ingress"
}

resource "aws_security_group_rule" "lb_ingress_tcp_http" {
  description       = "ingress TCP/80"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.lb.id
  to_port           = 80
  type              = "ingress"
}

resource "aws_security_group_rule" "lb_ingress_tcp_https" {
  description       = "ingress TCP/443"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.lb.id
  to_port           = 443
  type              = "ingress"
}

resource "aws_security_group" "ecs" {
  description = "sg for ecs"
  name        = format("%s-%s-ecs", var.account_name, var.environment)
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }


  tags = {
    Name = format("%s-%s-ecs", var.account_name, var.environment)
  }
}

resource "aws_security_group_rule" "ecs_egress_any" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "to any over any"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.ecs.id
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "ecs_itself_any" {
  description       = "itself"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.ecs.id
  self              = true
  to_port           = 0
  type              = "ingress"
}

resource "aws_security_group_rule" "ecs_ingress_lb_any" {
  description              = "from alb over any"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.ecs.id
  source_security_group_id = aws_security_group.lb.id
  to_port                  = 0
  type                     = "ingress"
}