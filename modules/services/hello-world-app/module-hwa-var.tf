variable "server_port" {
  description = "The port the server will use for HTTP connections"
  type        = number
  default     = 8080
}

variable "ami" {
  type    = string
  default = "ami-04e601abe3e1a910f"
}

variable "enable_new_user_data" {
  description = "If set to true, use the new User Data Script"
  type = bool
  default = false
}

variable "server_text" {
  description = "The text the web server should return"
  default = "Hello, World!"
  type = string
}

variable "cluster_name" {
  description = "The name to use for all the cluster resources"
  type        = string
}

variable "db_remote_state_bucket" {
  description = "The name of the S3 bucket for the db's remote state"
  type        = string
  default     = "terraform-up-and-running-state-it-ec2-lessons-42"
}

variable "db_remote_state_key" {
  description = "The path for the db's remote state in S3"
  type        = string
}

variable "instance_type" {
  description = "The type of EC2 Instances to run (e.g. t2.micro)"
  type        = string
  default     = "t2.micro"
}

variable "min_size" {
  description = "The minimum number of EC2 Instances in the ASG"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "The maximum number of EC2 Instances in the ASG"
  type        = number
  default     = 3
}

variable "enable_autoscaling" {
  description = "If set to true, enable autoscaling"
  type        = bool
}

variable "custom_tags" {
  description = "Custom tags to set on the instances in the ASG"
  type        = map(string)
  default     = {}
}

variable "user_names" {
  description = "Create IAM users with these names"
  type        = list(string)
  default     = ["neo", "trinity", "morpheus"]
}

variable "give_neo_cloudwatch_full_access" {
  description = "If true, neo gets full access to CloudWatch"
  type        = bool
  default = false
}

variable "policy_name_prefix" {
  description = "The prefix to use for the IAM policy names"
  type        = string
  default     = ""
}

variable "environment" {
  description = "The name of the environment we are deploing to"
  type        = string
}