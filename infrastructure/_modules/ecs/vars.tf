variable "account_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "aws_account_id" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "ecs" {
  type = any
}

variable "ecs_task_exec_role_arn" {
  type = string
}

variable "ecs_task_role_arn" {
  type = string
}

variable "codedeploy_role_arn" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "vpc_subnets_web_ids" {
  type = list(string)
}

variable "vpc_subnets_app_ids" {
  type = list(string)
}

variable "retention_in_days" {
  type = number
}

variable "certificate_arn" {
  type = string
}

variable "domain_name" {
  type = string
}