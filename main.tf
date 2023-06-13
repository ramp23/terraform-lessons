provider "aws" {
    region = "eu-central-1"
}

variable "server_port" {
    description = "The port the server will use for HTTP connections"
    type = number
    default = 8080
}

resource "aws_instance" "example1" {
    ami = "ami-0122fd36a4f50873a"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.instance.id]

    user_data = <<-EOF
                #!/bin/bash
                echo "Hello, World!" > index.html
                nohup busybox httpd -f -p ${var.server_port} &
                EOF

    tags = {
        Name = "terraform-example"
    }
}

resource "aws_security_group" "instance" {
    name = "terraform-example-instance"

    ingress {
        from_port = var.server_port
        to_port = var.server_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

output "public_ip" {
    value = aws_instance.example1.public_ip
}

resource "aws_launch_configuration" "example1" {
    image_id = "ami-0122fd36a4f50873a"
    instance_type = "t2.micro"
    security_groups = [aws_security_group.instance.id]

    user_data = <<-EOF
                #!/bin/bash
                echo "Hello, World!" > index.html
                nohup busybox httpd -f -p ${var.server_port} &
                EOF
}

resource "aws_autoscaling_group" "example1" {
    launch_configuration = aws_launch_configuration.example1.name
    vpc_zone_identifier = toset(data.aws_subnets.default.ids)

    min_size = 2
    max_size = 10

    tag {
        key = "Name"
        value = "terraform-asg-example"
        propagate_at_launch = true
    }

    lifecycle {
        create_before_destroy = true
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

output "subnet_cidr_blocks" {
  value = [for s in data.aws_subnet.default : s.cidr_block]
}