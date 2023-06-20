terraform {
  required_version = ">= 0.12, < 0.13"
}

provider "aws" {
  region = "eu-cental-1"

  # Allow any 2.x version of the AWS provider
  version = "~> 2.0"
}

module "alb" {
  source = "../../modules/networking/alb"

  alb_name   = var.alb_name
  subnet_ids = data.aws_subnets.default.ids
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_subnet" "default" {
  for_each = toset(data.aws_subnets.default.ids)
  id       = each.value
}