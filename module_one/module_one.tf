#####################################################################
# VARIABLES
#####################################################################

variable "aws_access_key" {
  type    = string
  default = "ASIA5547CE7RKGJABF7T"
}
variable "aws_secret_key" {
  type    = string
  default = "Qd8dCobuqW3Bxfxsjr40ocp4JLm11XzlGYYxJWlm"
}

variable "aws_session_token" {
  type    = string
  default = "FwoGZXIvYXdzEDQaDM+D+3kbuSQgT3xa8CKuAcg3x801g9RH//g+KFkI1FeT80c7oSfS4b2mVHhzgD+wHI8v4xMYOM7ZgqcfXxs2CVww6LUPB/ePQPrqqfmPqNwgjVM2/4HVL3+cguvA+6AOyfQViIb8HRp3olNlBPTkShr1AKlZgv9Y9l4zJoNInrBHZX+KcQwsvzrG+fUm+HBl5HhubW1KmkUzgiwOJKDOzFYHonUGr+MxdxxNh1/C0wj1bQxGsCBViFBwKq7Q9yiA4tf+BTItNDwmaH6zgiMx5F9fqhoE+hp3yH7ztZ21Ys+b5dTUbC/NH9YirfyrXj35uu6o"
}

variable "private_key_path" {
  type    = string
  default = "./key"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

#####################################################################
# PROVIDERS
#####################################################################

provider "aws" {
  region     = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  token      = var.aws_session_token
}

#####################################################################
# DATA
#####################################################################

data "aws_subnet_ids" "default_subnet_id" {
  vpc_id = aws_default_vpc.default.id
}

#####################################################################
# RESOURCES
#####################################################################

resource "aws_default_vpc" "default" {}
resource "aws_security_group" "webserver_security_group" {
  name        = "Webserver"
  description = "The security group of all of the webservers"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["84.195.18.71/32", "84.194.49.69/32", "193.190.154.173/32", "193.190.154.174/32", "193.190.154.175/32", "193.190.154.176/32"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  
}

resource "aws_security_group" "database_security_group" {
  name        = "Database"
  description = "The security group of the database"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.webserver_security_group.id]
  }

  egress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.webserver_security_group.id]
  }
}

resource "aws_security_group_rule" "webserver_security_group_edit1" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  security_group_id = aws_security_group.webserver_security_group.id
  source_security_group_id = aws_security_group.database_security_group.id
  depends_on = [
    aws_security_group.webserver_security_group,
  ]
}

resource "aws_security_group_rule" "webserver_security_group_edit2" {
  type              = "egress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  security_group_id = aws_security_group.webserver_security_group.id
  source_security_group_id = aws_security_group.database_security_group.id
  depends_on = [
    aws_security_group.webserver_security_group,
  ]
}

module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "webserverdb"
  username   = "admin"
  password   = "JensThomas05"
  port       = 3306

  instance_class       = "db.t3.small"
  engine               = "mysql"
  engine_version       = "5.7.19"
  major_engine_version = "5.7"
  family               = "mysql5.7"
  allocated_storage    = 5

  backup_window      = "03:00-06:00"
  maintenance_window = "Mon:00:00-Mon:03:00"

  subnet_ids = data.aws_subnet_ids.default_subnet_id.ids
  vpc_security_group_ids = [aws_security_group.database_security_group.id]
}

resource "tls_private_key" "webserver_private_key" {
  algorithm = "RSA"
}

module "key_pair" {
  source     = "terraform-aws-modules/key-pair/aws"
  key_name   = "Webserver"
  public_key = tls_private_key.webserver_private_key.public_key_openssh
}

resource "local_file" "key_file" {
  content  = tls_private_key.webserver_private_key.private_key_pem
  filename = "Webserver.pem"
}

resource "aws_s3_bucket" "bucket" {
  bucket = "webserver.groep5"
  acl = "public-read"

  tags = {
    Name = "webserver.groep5"
  }
}
resource "aws_s3_bucket_public_access_block" "bucket_access_list" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls   = false
  block_public_policy = true
}
resource "aws_s3_bucket_object" "image1" {
  bucket = aws_s3_bucket.bucket.id
  key    = "fjords.jpg"
  source = "./images/fjords.jpg"
  etag = filemd5("./images/fjords.jpg")
  acl = "public-read"
}
resource "aws_s3_bucket_object" "image2" {
  bucket = aws_s3_bucket.bucket.id
  key    = "lights.jpg"
  source = "./images/lights.jpg"
  etag = filemd5("./images/lights.jpg")
  acl = "public-read"
}
resource "aws_s3_bucket_object" "image3" {
  bucket = aws_s3_bucket.bucket.id
  key    = "nature.jpg"
  source = "./images/nature.jpg"
  etag = filemd5("./images/nature.jpg")
  acl = "public-read"
}

#####################################################################
# OUTPUT
#####################################################################

resource "local_file" "localhost_yml" {
  content  = <<-DOC
    # Ansible vars_file containing variable values from Terraform.
    # Generated by Terraform mgmt configuration.

    AWS__Database_ip: "${module.db.this_db_instance_address}"
    AWS__Database_username: "admin"
    AWS__Database_password: "JensThomas05"
    AWS__Database_name: "employees"
    AWS__S3_bucket_url: "https://s3.amazonaws.com/webserver.groep5"
    DOC
  filename = "./ansible/plays/host_vars/localhost.yml"
}

output "this_db_instance_address" {
  description = "The address of the RDS instance"
  value       = module.db.this_db_instance_address
}
