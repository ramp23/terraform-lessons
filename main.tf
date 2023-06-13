provider "aws" {
    region = "eu-central-1"
}

resource "aws_instance" example1 {
    ami = "ami-0122fd36a4f50873a"
    instance_type = "t2.micro"
    tags = {
        Name = "terraform-example"
    }
}