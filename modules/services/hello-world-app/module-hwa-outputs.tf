output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "instance_security_group_id" {
  value       = aws_security_group.instance.id
  description = "The ID of the EC2 Instance Security Group"
}
output "asg_name" {
  value       = module.asg.asg_name
  description = "The name of the Auto Scaling Group"
}
