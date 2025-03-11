variable "region" {
  default = "us-east-1"
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

variable "subnet_ids" {
  description = "List of subnet IDs in different AZs"
  type        = list(string)
  default     = ["subnet-0df25e6d4c904dbfb", "subnet-0bffacb83d828c341"]  # Update with at least two subnet IDs
}
