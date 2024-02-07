resource "aws_launch_template" "nat" {
  depends_on = [aws_route_table.private]
  image_id               = data.aws_ami.amzn2.id
  instance_type          = "t2.nano"
  name_prefix            = format("%s-%s-nat", var.account_name, var.environment)
  update_default_version = true
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = "30"
    }
  }
  iam_instance_profile {
    name = aws_iam_instance_profile.nat.name
  }
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }
  monitoring {
    enabled = false
  }
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.nat.id]
  }
  user_data = local.cloud_init_nat
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "nat" {
  depends_on = [aws_route_table.private]
  for_each = var.ngw_ec2 ? toset(sort(data.aws_availability_zones.this.zone_ids)) : toset([])
  desired_capacity  = "1"
  health_check_type = "EC2"
  launch_template {
    id      = aws_launch_template.nat.id
    version = "$Latest"
  }
  max_size            = 1
  min_size            = 1
  name                = format("%s-%s-nat-%s", var.account_name, var.environment, each.value)
  vpc_zone_identifier = [aws_subnet.nat[each.value].id]

  tag {
    key                 = "Name"
    value               = format("%s-%s-nat-%s", var.account_name, var.environment, each.value)
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.account_name
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "Managed"
    propagate_at_launch = true
    value               = "terraform"
  }
}