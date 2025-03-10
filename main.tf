provider "aws" {
  region     = var.region
  assume_role {
    role_arn = "arn:aws:iam::891377168016:role/Terraform-ec2"
  }
}

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
  subnet_ids = [var.subnet_id]

  tags = {
    Name = "SonarQube DB Subnet Group"
  }
}

resource "aws_instance" "sonarqube" {
  ami                    = "ami-0c55b159cbfafe1f0" # Update with latest Ubuntu AMI
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.sonarqube_sg.id]
  key_name               = "your-key-pair" # Update with your EC2 key pair

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y docker.io
              systemctl start docker
              systemctl enable docker

              docker run -d --name sonarqube \
                -p 9000:9000 \
                -e SONAR_JDBC_URL=jdbc:postgresql://${aws_db_instance.sonarqube_db.address}:5432/sonarqube \
                -e SONAR_JDBC_USERNAME=${var.db_username} \
                -e SONAR_JDBC_PASSWORD=${var.db_password} \
                sonarqube:lts
              EOF

  tags = {
    Name = "SonarQube-Instance"
  }
}
