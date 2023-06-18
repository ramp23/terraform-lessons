data "template_file" "user_data" {
  count    = var.enable_new_user_data ? 0 : 1
  template = file("${path.module}/user_data.sh")

  vars = {
    server_port = var.server_port
    db_address  = data.terraform_remote_state.db.outputs.address
    db_port     = data.terraform_remote_state.db.outputs.port
  }
}

data "template_file" "user_data_new" {
  count    = var.enable_new_user_data ? 1 : 0
  template = file("${path.module}/user_data_new.sh")

  vars = {
    server_port = var.server_port
    # db_address  = data.terraform_remote_state.db.outputs.address
    # db_port     = data.terraform_remote_state.db.outputs.port
  }
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

data "terraform_remote_state" "db" {
  backend = "s3"

  config = {
    bucket  = var.db_remote_state_bucket
    key     = var.db_remote_state_key
    region  = "eu-central-1"
    profile = "default"
  }
}