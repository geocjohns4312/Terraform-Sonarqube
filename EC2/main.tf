module "psql" {
  source = "../RDS/"
  region = var.region
  db_username = var.db_username
  db_password = var.db_password
  vpc_id = var.vpc_id
  subnet_ids = var.subnet_ids
}


resource "aws_instance" "sonarqube" {
  ami                    = "ami-08b5b3a93ed654d19" # Update with latest Amazon linux AMI
  instance_type          = "t3.medium"
  subnet_id             = var.subnet_id
  vpc_security_group_ids = [module.psql.sonarqube_sg_id]
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
                -e SONAR_JDBC_URL=jdbc:postgresql://${module.psql.sonarqube_db_address}:5432/sonarqube \
                -e SONAR_JDBC_USERNAME=${var.db_username} \
                -e SONAR_JDBC_PASSWORD=${var.db_password} \
                sonarqube:lts
              EOF

  tags = {
    Name = "SonarQube-Instance"
  }
}
