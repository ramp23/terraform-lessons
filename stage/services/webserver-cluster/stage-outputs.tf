output "alb_dns_name" {
  value = module.webserver_cluster.alb_dns_name
}

# output "public_ip_one_server" {
#   value = aws_instance.example1.public_ip
# }

# output "subnet_cidr_blocks" {
#   value = [for s in data.aws_subnet.default : s.cidr_block]
# }

# output "fingerprint" {
#   value = aws_key_pair.terraform_example_key.public_key
# }

# output "key name" {
#   value = aws_key_pair.terraform_example_key.key_name
# }

# output "key id" {
#   value = aws_key_pair.terraform_example_key.id
# }
