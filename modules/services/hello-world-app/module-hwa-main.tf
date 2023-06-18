module "asg" {
    source = "../../cluster/asg-rolling-deploy"

    cluster_name = "${var.environment}-hello-world"
    ami = var.ami
    user_data = data.template_file.user_data.rendered
    instance_type = var.instance_type

    min_size = var.min_size
    max_size = var.max_size
    enable_autoscaling = var.enable_autoscaling

    subnet_ids = data.aws_subnet_ids.default.ids
    target_group_ars = [aws_lb_target_group.asg.arn]
    health_check_type = "ELB"

    custom_tags = var.custom_tags
}

module "alb" {
    source = "../../networking/alb"
    alb_name = "${var.environment}-hello-world"
    subnet_ids = data.aws_subnet_ids.default.ids
}