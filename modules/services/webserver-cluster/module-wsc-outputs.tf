output "public_ip_one_server" {
  value = aws_instance.example1.public_ip
}

output "alb_dns_name" {
  value = aws_lb.example.dns_name
}

output "subnet_cidr_blocks" {
  value = [for s in data.aws_subnet.default : s.cidr_block]
}

output "asg_name" {
  value       = aws_autoscaling_group.example1.name
  description = "The name of the Auto Scaling Group"
}

output "alb_security_group_id" {
  value       = aws_security_group.alb.id
  description = "The ID of the Security Group attached to the load balancer"
}


# output "fingerprint" {
#   value = aws_key_pair.terraform_example_key.public_key
# }

# output "key name" {
#   value = aws_key_pair.terraform_example_key.key_name
# }

# output "key id" {
#   value = aws_key_pair.terraform_example_key.id
# }
