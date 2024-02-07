output "data_aws_availability_zones" {
  value = data.aws_availability_zones.this
}

output "vpc_id" {
  value = aws_vpc.this.id
}

output "vpc_subnets_web_ids" {
  value = values(aws_subnet.web)[*].id
}

output "vpc_subnets_nat_ids" {
  value = values(aws_subnet.nat)[*].id
}

output "vpc_subnets_app_ids" {
  value = values(aws_subnet.app)[*].id
}

output "vpc_subnets_db_ids" {
  value = values(aws_subnet.db)[*].id
}