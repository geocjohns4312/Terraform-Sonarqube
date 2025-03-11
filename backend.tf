terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-4312"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}
