

resource "aws_security_group" "sonarqube_ec2_sg" {
  name        = "sonarqube_ec2_sg"
  description = "Allow HTTP and SSH for SonarQube"
  vpc_id      = var.vpc_id

  # Allow HTTP (SonarQube UI)
  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Restrict to your IP for security
  }

  # Allow SSH (Optional - for debugging)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Replace with your IP for security
  }

  # Allow outbound connections to RDS
   egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # "-1" means all protocols
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }

  tags = {
    Name = "SonarQube-EC2-SG"
  }
}

resource "aws_instance" "sonarqube" {
  ami                    = "ami-08b5b3a93ed654d19" # Update with latest Amazon linux AMI
  instance_type          = "t3.medium"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.sonarqube_ec2_sg.id]
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
                -e SONAR_JDBC_URL=jdbc:postgresql://${var.sonarqube_db_address}:5432/sonarqube \
                -e SONAR_JDBC_USERNAME=${var.db_username} \
                -e SONAR_JDBC_PASSWORD=${var.db_password} \
                sonarqube:lts
              EOF
  tags = {
    Name = "SonarQube-Instance"
  }
}
