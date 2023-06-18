resource "aws_instance" "example1" {
  ami                         = var.ami
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.instance.id]
  user_data_replace_on_change = true

  user_data = data.template_file.user_data.rendered

  tags = {
    Name = "${var.cluster_name}"
  }
}

locals {
  http_port    = 80
  any_port     = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips      = ["0.0.0.0/0"]
}

resource "aws_launch_configuration" "example1" {
  name            = var.cluster_name
  image_id        = var.ami
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.instance.id]

  user_data = data.template_file.user_data.rendered
}

# resource "aws_network_acl" "main" {
#     vpc_id = data.aws_vpc.default.id
#     subnet_ids = toset(data.aws_subnets.default.ids)

#     ingress {
#         protocol   = "tcp"
#         rule_no    = 100
#         action     = "allow"
#         cidr_block = "10.3.0.0/18"
#         from_port  = 8080
#         to_port    = 8080
#     }

#     ingress {
#         protocol   = "tcp"
#         rule_no    = 200
#         action     = "allow"
#         cidr_block = "213.134.172.224/32"
#         from_port  = 22
#         to_port    = 22
#     }

#     tags = {
#         Name = "terraform-ec2-acl"
#     }
# }
# resource "aws_key_pair" "terraform_example_key" {
#     key_name   = "terraform-id-rsa-ec2"
#     public_key = file("/home/bear/.ssh/id_rsa_ec2.pub")
# }

# data "aws_key_pair" "terraform_example" {
#     key_name           = "${var.cluster-name}"
#     include_public_key = true
#     filter {
#         name   = "tag:terraform"
#         values = ["learning"]
#     }
# }

