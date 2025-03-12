module "ec2" {
    source = "./EC2/"
    region = var.region
    db_username = var.db_username
    db_password = var.db_password
    vpc_id = var.vpc_id
    subnet_id = var.subnet_id
    subnet_ids = var.subnet_ids
}