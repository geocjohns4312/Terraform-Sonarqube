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
  subnet_ids = var.subnet_ids

  tags = {
    Name = "SonarQube DB Subnet Group"
  }
}

resource "aws_instance" "sonarqube" {
  ami                    = "ami-08b5b3a93ed654d19" # Update with latest Amazon linux AMI
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.sonarqube_sg.id]
  key_name               = "mrinal" # Update with your EC2 key pair

   user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              systemctl start docker
              systemctl enable docker

              # Increase vm.max_map_count for Elasticsearch
              echo "vm.max_map_count=262144" >> /etc/sysctl.conf
              sysctl -w vm.max_map_count=262144

              # Run SonarQube in Docker
              docker run -d --name sonarqube \
                -p 9000:9000 \
                --ulimit nofile=65536:65536 \
                --ulimit nproc=4096:4096 \
                -e SONAR_JDBC_URL=jdbc:postgresql://${aws_db_instance.sonarqube_db.address}:5432/sonarqube \
                -e SONAR_JDBC_USERNAME=${var.db_username} \
                -e SONAR_JDBC_PASSWORD=${var.db_password} \
                sonarqube:lts
              EOF

  tags = {
    Name = "SonarQube-Instance"
  }
}
