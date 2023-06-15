provider "aws" {
    region = "eu-central-1"
}

resource "aws_s3_bucket" "terraform_state" {
    bucket = "terraform-up-and-running-state-it-ec2-lessons-42"

    lifecycle {
        prevent_destroy = true
    }

}

resource "aws_kms_key" "terraform_state_bucket_encryption_key" {
    description             = "This key is used to encrypt bucket objects"
    deletion_window_in_days = 10
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_bucket_encryption" {
    bucket = aws_s3_bucket.terraform_state.id

    rule {
        apply_server_side_encryption_by_default {
            kms_master_key_id = aws_kms_key.terraform_state_bucket_encryption_key.arn
            sse_algorithm     = "aws:kms"
        }
    }
}

resource "aws_s3_bucket_versioning" "terraform_state_bucket_versioning" {
    bucket = aws_s3_bucket.terraform_state.id

    versioning_configuration {
        status = "Enabled"
    }
}

resource "aws_s3_bucket_public_access_block" "terraform_state_public_access_block" {
    bucket = aws_s3_bucket.terraform_state.id

    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform_locks" {
    name = "terraform-up-and-running-locks"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"

    attribute {
        name = "LockID"
        type = "S"
    }
}

terraform {
    backend "s3" {
        bucket = "terraform-up-and-running-state-it-ec2-lessons-42"
        key = "global/s3/terraform.tfstate"
        region = "eu-central-1"
        profile = "default"
        shared_credentials_file = "/home/bear/.aws/credentials"
        dynamodb_table = "terraform-up-and-running-locks"
        encrypt = true
    }
}