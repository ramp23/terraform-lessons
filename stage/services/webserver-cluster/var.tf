variable "server_port" {
    description = "The port the server will use for HTTP connections"
    type = number
    default = 8080
}

variable "ami" {
    type = string
    default = "ami-04e601abe3e1a910f"
}