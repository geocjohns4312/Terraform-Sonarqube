output "sonarqube_url" {
  description = "URL to access the SonarQube instance"
  value       = "http://${aws_instance.sonarqube.public_ip}:9000"
}
