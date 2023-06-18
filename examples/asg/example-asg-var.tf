variable "cluster_name" {
  description = "The name to use for all the cluster resources"
  type        = string
  default = "example"
}

variable "ami" {
  type    = string
  default = "ami-04e601abe3e1a910f"
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