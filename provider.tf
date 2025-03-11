provider "aws" {
  region     = var.region
  assume_role {
    role_arn = "arn:aws:iam::891377168016:role/Terraform-ec2"
  }
}