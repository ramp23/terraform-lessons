resource "aws_lb_target_group" "asg" {
  name     = "${var.environment}-asg"
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
  listener_arn = module.alb.alb_http_listener.arn
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