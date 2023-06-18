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

resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  count                 = var.enable_autoscaling ? 1 : 0
  scheduled_action_name = "scale-out-during-business-hours"
  min_size              = 2
  max_size              = 10
  desired_capacity      = 10
  recurrence            = "0 9 * * *"

  autoscaling_group_name = aws_autoscaling_group.example1.name
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
  count                 = var.enable_autoscaling ? 1 : 0
  scheduled_action_name = "scale-in-at-night"
  min_size              = 2
  max_size              = 10
  desired_capacity      = 2
  recurrence            = "0 17 * * *"

  autoscaling_group_name = aws_autoscaling_group.example1.name
}


locals {
  http_port    = 80
  any_port     = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips      = ["0.0.0.0/0"]
}

resource "aws_security_group" "instance" {
  name = "${var.cluster_name}-instance"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = local.tcp_protocol
    cidr_blocks = ["213.134.172.224/32"]
  }

  ingress {
    from_port   = local.http_port
    to_port     = local.http_port
    protocol    = local.tcp_protocol
    cidr_blocks = local.all_ips
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "example1" {
  name            = var.cluster_name
  image_id        = var.ami
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.instance.id]

  user_data = data.template_file.user_data.rendered
}

resource "aws_autoscaling_group" "example1" {
  launch_configuration = aws_launch_configuration.example1.name
  vpc_zone_identifier  = toset(data.aws_subnets.default.ids)

  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  min_size = 2
  max_size = 3

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-asg"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.custom_tags

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/user_data.sh")

  vars = {
    server_port = var.server_port
    db_address  = data.terraform_remote_state.db.outputs.address
    db_port     = data.terraform_remote_state.db.outputs.port
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
  name               = "${var.cluster_name}-lb"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port              = local.http_port
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

resource "aws_security_group" "alb" {
  name = "${var.cluster_name}-alb"

  ingress {
    from_port   = local.http_port
    to_port     = local.http_port
    protocol    = local.tcp_protocol
    cidr_blocks = local.all_ips
  }

  egress {
    from_port   = local.any_port
    to_port     = local.any_port
    protocol    = local.any_protocol
    cidr_blocks = local.all_ips
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "asg" {
  name     = "${var.cluster_name}-asg"
  port     = var.server_port
  protocol = "HTTP"

  vpc_id = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 20
    timeout             = 15
    healthy_threshold   = 10
    unhealthy_threshold = 10
  }
}

resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
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

