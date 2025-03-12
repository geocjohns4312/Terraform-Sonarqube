output "sonarqube_sg_id" {
  value = aws_security_group.sonarqube_sg.id
}

output "sonarqube_db_address" {
  value = aws_db_instance.sonarqube_db.address
}
