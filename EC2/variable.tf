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

variable "subnet_id" {
  description = "Sonar Subnet ID"
}

variable "sonarqube_db_address" {
  description = "SonarQube database endpoint"
}