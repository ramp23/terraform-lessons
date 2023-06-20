provider "aws" {
    region = "eu-central-1"
}

module "asg" {
    source = "../../modules/cluster/asg-rolling-deploy"

    cluster_name = var.cluster_name
    ami = var.ami
    user_data = data.template_file.user_data.rendered
    instance_type = var.instance_type

    min_size = var.min_size
    max_size = var.max_size
    enable_autoscaling = var.enable_autoscaling

    subnet_ids = [for s in data.aws_subnet.default : s.cidr_block]
}

data "template_file" "user_data" {
  template = file("${path.module}/user_data.sh")

  vars = {
    server_port = "8080"
    db_address  = "localhost"
    db_port     = "5553"
    server_text = "Welcome to example"
  }
}