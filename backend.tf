provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "my-terraform-state-bucket-4312"

  lifecycle {
    prevent_destroy = true  # Prevents accidental deletion
  }
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-4312"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}
