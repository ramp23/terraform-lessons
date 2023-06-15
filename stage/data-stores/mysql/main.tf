provider "aws" {
    region = "eu-central-1"
}

resource "aws_db_instance" "example" {
    identifier_prefix = "terraform-up-and-running-ramp23"
    engine = "mysql"
    allocated_storage = 10
    instance_class = "db.t2.micro"
    db_name = "example_database"
    username = "admin"
    password = var.db_password
    skip_final_snapshot = true
}

terraform {
    backend "s3" {
        bucket = "terraform-up-and-running-state-it-ec2-lessons-42"
        key = "global/data-stores/terraform.tfstate"
        region = "eu-central-1"
        profile = "default"
        shared_credentials_file = "/home/bear/.aws/credentials"
        dynamodb_table = "terraform-up-and-running-locks"
        encrypt = true
    }
}

data "terraform_remote_state" "db" {
    backend = "s3"

    config = {
        bucket = "terraform-up-and-running-state-it-ec2-lessons-42"
        key = "global/data-stores/terraform.tfstate"
        region = "eu-central-1"
    }
}