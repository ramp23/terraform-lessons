provider "aws" {
    region = "eu-central-1"
}

resource "aws_instance" "example1" {
    ami = var.ami
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.instance.id]
    user_data_replace_on_change = true

    user_data = data.template_file.user_data.rendered

    tags = {
        Name = "terraform-example"
    }
}

resource "aws_security_group" "instance" {
    name = "terraform-example-instance"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["213.134.172.224/32"]
    }

    ingress {
        from_port = var.server_port
        to_port = var.server_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_launch_configuration" "example1" {
    image_id = var.ami
    instance_type = "t2.micro"
    security_groups = [aws_security_group.instance.id]

    user_data = data.template_file.user_data.rendered
}

resource "aws_autoscaling_group" "example1" {
    launch_configuration = aws_launch_configuration.example1.name
    vpc_zone_identifier = toset(data.aws_subnets.default.ids)

    target_group_arns = [aws_lb_target_group.asg.arn]
    health_check_type = "ELB"

    min_size = 2
    max_size = 3

    tag {
        key = "Name"
        value = "terraform-asg-example"
        propagate_at_launch = true
    }

    lifecycle {
        create_before_destroy = true
    }
}

data "template_file" "user_data" {
    template = file("user_data.sh")

    vars = {
        server_port = var.server_port
        db_address = data.terraform_remote_state.db.outputs.address
        db_port = data.terraform_remote_state.db.outputs.port
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

resource "aws_lb" "example" {
    name = "terraform-asg-example"
    load_balancer_type = "application"
    subnets = data.aws_subnets.default.ids
    security_groups = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.example.arn
    port = 80
    protocol = "HTTP"

    default_action {
        type = "fixed-response"

        fixed_response {
            content_type = "text/plain"
            message_body = "404: page not found"
            status_code = 404
        }
    }
}

resource "aws_security_group" "alb" {
    name = "terraform-example-alb"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_lb_target_group" "asg" {
    name = "terraform-asg-example"
    port = var.server_port
    protocol = "HTTP"

    vpc_id = data.aws_vpc.default.id

    health_check {
        path = "/"
        protocol = "HTTP"
        matcher = "200"
        interval = 20
        timeout = 15
        healthy_threshold = 10
        unhealthy_threshold = 10
    }
}

resource "aws_lb_listener_rule" "asg" {
    listener_arn = aws_lb_listener.http.arn
    priority = 100

    condition {
        path_pattern {
            values = ["*"]
        }
    }

    action {
        type = "forward"
        target_group_arn = aws_lb_target_group.asg.arn
    }
}

data "terraform_remote_state" "db" {
    backend = "s3"

    config = {
        bucket = "terraform-up-and-running-state-it-ec2-lessons-42"
        key = "global/data-stores/terraform.tfstate"
        region = "eu-central-1"
    }
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
#     key_name           = "terraform-example"
#     include_public_key = true
#     filter {
#         name   = "tag:terraform"
#         values = ["learning"]
#     }
# }

