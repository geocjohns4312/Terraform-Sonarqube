variable "region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t3.medium"
}

variable "db_username" {
  default = "sonar"
}

variable "db_password" {
  default = "StrongPassword123!"
}

variable "vpc_id" {
  description = "VPC ID"
  default     = "vpc-0c8a4597547b23ff0"  # Set your VPC ID here
}

variable "subnet_id" {
  description = "Subnet ID"
  default     = "subnet-0df25e6d4c904dbfb"  # Set your Subnet ID here
}
