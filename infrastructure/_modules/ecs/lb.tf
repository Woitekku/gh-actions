resource "aws_lb_target_group" "this" {
  for_each             = var.ecs.services_ext
  deregistration_delay = 120
  health_check {
    enabled             = each.value.health_check.enabled
    healthy_threshold   = each.value.health_check.healthy_threshold
    interval            = each.value.health_check.interval
    matcher             = each.value.health_check.matcher
    path                = each.value.health_check.path
    port                = each.value.health_check.port
    protocol            = each.value.health_check.protocol
    timeout             = each.value.health_check.timeout
    unhealthy_threshold = each.value.health_check.unhealthy_threshold
  }
  name        = format("%s-%s-%s", var.account_name, var.environment, each.key)
  port        = each.value.port
  protocol    = each.value.protocol
  target_type = "ip"
  vpc_id      = var.vpc_id

  tags = {
    Name = format("%s-%s", var.account_name, var.environment)
  }
}

resource "aws_lb" "this" {
  count                      = length(var.ecs.services_ext) > 0 ? 1 : 0
  drop_invalid_header_fields = true
  internal                   = false
  load_balancer_type         = "application"
  name                       = format("%s-%s", var.account_name, var.environment)
  security_groups            = [aws_security_group.lb.id]
  subnets                    = var.vpc_subnets_web_ids

  tags = {
    Name        = format("%s-%s", var.account_name, var.environment)
  }
}

resource "aws_lb_listener" "http" {
  count = length(var.ecs.services_ext) > 0 ? 1 : 0
  load_balancer_arn = aws_lb.this[0].arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "redirect"

    redirect {
      host        = "#{host}"
      port        = "443"
      path        = "/#{path}"
      protocol    = "HTTPS"
      query       = "#{query}"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
    count                      = length(var.ecs.services_ext) > 0 ? 1 : 0
  certificate_arn = var.certificate_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this["app"].arn
  }
  load_balancer_arn = aws_lb.this[0].arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  tags = {
    Name        = format("%s-%s", var.account_name, var.environment)
  }
}
