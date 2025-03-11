resource "aws_security_group" "sonarqube_sg" {
  name        = "sonarqube-sg"
  description = "Allow access to SonarQube"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict this for security
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict for SSH access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



resource "aws_db_instance" "sonarqube_db" {
  identifier           = "sonarqube-db"
  allocated_storage    = 20
  engine              = "postgres"
  engine_version      = "14"
  instance_class      = "db.t3.micro"
  username           = var.db_username
  password           = var.db_password
  parameter_group_name = "default.postgres14"
  publicly_accessible = false
  skip_final_snapshot = true
  vpc_security_group_ids = [aws_security_group.sonarqube_sg.id]
  db_subnet_group_name = aws_db_subnet_group.sonarqube_subnet_group.name
}

resource "aws_db_subnet_group" "sonarqube_subnet_group" {
  name       = "sonarqube-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "SonarQube DB Subnet Group"
  }
}
