variable "server_port" {
  description = "The port the server will use for HTTP connections"
  type        = number
  default     = 8080
}

variable "ami" {
  type    = string
  default = "ami-04e601abe3e1a910f"
}

variable "db_remote_state_bucket" {
  description = "The name of the S3 bucket used for the database's remote state storage"
  type        = string
  default     = "terraform-up-and-running-state-it-ec2-lessons-42"
}

variable "db_remote_state_key" {
  description = "The name of the key in the S3 bucket used for the database's remote state storage"
  type        = string
  default     = "stage/data-stores/mysql/terraform.tfstate"
}
