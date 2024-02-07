resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = format("%s-%s", var.account_name, var.environment)
  }
}

resource "aws_subnet" "reserved" {
  for_each = toset(sort(data.aws_availability_zones.this.zone_ids))

  availability_zone_id    = each.value
  cidr_block              = cidrsubnet(var.cidr_block, 4, index(sort(data.aws_availability_zones.this.zone_ids), each.value))
  map_public_ip_on_launch = false
  vpc_id                  = aws_vpc.this.id

  tags = {
    Name = format("%s-%s-res-%s", var.account_name, var.environment, each.value)
  }
}

resource "aws_subnet" "web" {
  for_each = toset(sort(data.aws_availability_zones.this.zone_ids))

  availability_zone_id    = each.value
  cidr_block              = cidrsubnet(var.cidr_block, 4, index(sort(data.aws_availability_zones.this.zone_ids), each.value) + 3)
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.this.id

  tags = {
    Name = format("%s-%s-web-%s", var.account_name, var.environment, each.value)
  }
}

resource "aws_subnet" "nat" {
  for_each = toset(sort(data.aws_availability_zones.this.zone_ids))

  availability_zone_id    = each.value
  cidr_block              = cidrsubnet(var.cidr_block, 4, index(sort(data.aws_availability_zones.this.zone_ids), each.value) + 6)
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.this.id

  tags = {
    Name = format("%s-%s-nat-%s", var.account_name, var.environment, each.value)
  }
}

resource "aws_subnet" "app" {
  for_each = toset(sort(data.aws_availability_zones.this.zone_ids))

  availability_zone_id    = each.value
  cidr_block              = cidrsubnet(var.cidr_block, 4, index(sort(data.aws_availability_zones.this.zone_ids), each.value) + 9)
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.this.id

  tags = {
    Name = format("%s-%s-app-%s", var.account_name, var.environment, each.value)
  }
}

resource "aws_subnet" "db" {
  for_each = toset(sort(data.aws_availability_zones.this.zone_ids))

  availability_zone_id    = each.value
  cidr_block              = cidrsubnet(var.cidr_block, 4, index(sort(data.aws_availability_zones.this.zone_ids), each.value) + 12)
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.this.id

  tags = {
    Name = format("%s-%s-db-%s", var.account_name, var.environment, each.value)
  }
}



resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = format("%s-%s", var.account_name, var.environment)
  }
}

resource "aws_eip" "this" {
  depends_on = [aws_internet_gateway.this]
  for_each   = toset(sort(data.aws_availability_zones.this.zone_ids))

  domain = "vpc"

  tags = {
    Name = format("%s-%s-nat-%s", var.account_name, var.environment, each.value)
  }
}

resource "aws_nat_gateway" "this" {
  depends_on = [aws_internet_gateway.this]
  for_each   = var.ngw_ec2 ? toset([]) : toset(sort(data.aws_availability_zones.this.zone_ids))

  allocation_id = aws_eip.this[each.value].id
  subnet_id     = aws_subnet.web[each.value].id

  tags = {
    Name = format("%s-%s-%s", var.account_name, var.environment, each.value)
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = format("%s-%s-pub", var.account_name, var.environment)
  }
}

resource "aws_route_table" "private" {
  for_each = toset(sort(data.aws_availability_zones.this.zone_ids))

  vpc_id = aws_vpc.this.id

  tags = {
    Name = format("%s-%s-prv-%s", var.account_name, var.environment, each.value)
  }
}

resource "aws_route_table_association" "reserved" {
  for_each = toset(sort(data.aws_availability_zones.this.zone_ids))

  route_table_id = aws_route_table.private[each.value].id
  subnet_id      = aws_subnet.reserved[each.value].id
}

resource "aws_route_table_association" "web" {
  for_each = toset(sort(data.aws_availability_zones.this.zone_ids))

  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.web[each.value].id
}

resource "aws_route_table_association" "app" {
  for_each = toset(sort(data.aws_availability_zones.this.zone_ids))

  route_table_id = aws_route_table.private[each.value].id
  subnet_id      = aws_subnet.app[each.value].id
}

resource "aws_route_table_association" "db" {
  for_each = toset(sort(data.aws_availability_zones.this.zone_ids))

  route_table_id = aws_route_table.private[each.value].id
  subnet_id      = aws_subnet.db[each.value].id
}

resource "aws_route_table_association" "nat" {
  for_each = toset(sort(data.aws_availability_zones.this.zone_ids))

  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.nat[each.value].id
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route" "private" {
  for_each               = var.ngw_ec2 ? toset([]) : toset(sort(data.aws_availability_zones.this.zone_ids))
  route_table_id         = aws_route_table.private[each.value].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[each.value].id
}