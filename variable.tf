variable "region" {
  description = "AWS Region"
}


variable "db_username" {
  description = "psql username"
}

variable "db_password" {
  description = "psql password"
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "subnet_ids" {
  description = "List of subnet IDs in different AZs"
  type        = list(string)
}

variable "subnet_id" {
  description = "Sonar Subnet ID"
}