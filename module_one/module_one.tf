#####################################################################
# VARIABLES
#####################################################################

variable "aws_access_key" {
  type = string
  default = "ASIA5547CE7RMHGACBPD"
}
variable "aws_secret_key" {
  type = string
  default = "aUFw2Qo7J9RJqF91jE6rE8B6fQbWnOWOstb/TzoP"
}

variable "aws_session_token" {
  type = string
  default = "FwoGZXIvYXdzEB8aDDYxIaEwnkGYBEcJFCKuAaVXec6VG6mdbyMGLAc9LRY6wKvzJ27oMW0PGatBhl/eE8gGZmAz4rhzWSpue9j66ylBUZAGbpP7a0MNzndrno77kyezANH9J0vxVWbDB03e26020mtX2N5I/Vn4lh7fNCwUfZnbLu/GUmvXwabj1r47yAj9q8JLr0JwfHRZk2ok4VVK6+fT9kVSyCzasPnXGY6qMnaGlq/DX5fNVuDvNXP8Qq3kI26Rw1AsCc6sYyjLg9P+BTItlsgxE2+Vwr1yVT7boRZRULXmpOpqdiwjI8AqIgrbpB5DFS/ef/fwDpVADaqj"
}

variable "private_key_path" {
  type = string
  default = "./key"
}

variable "region" {
  type = string
  default = "us-east-1"
}

#####################################################################
# PROVIDERS
#####################################################################

provider "aws" {
  region = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  token = var.aws_session_token
}

#####################################################################
# RESOURCES
#####################################################################

resource "aws_default_vpc" "default" {}
resource "aws_security_group" "webserver_security_group" {
  name = "Webserver"
  description = "The security group of all of the webservers"
  vpc_id = aws_default_vpc.default.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["84.195.18.71/32","84.194.49.69/32","193.190.154.173/32","193.190.154.174/32","193.190.154.175/32","193.190.154.176/32"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["84.195.18.71/32","84.194.49.69/32","193.190.154.173/32","193.190.154.174/32","193.190.154.175/32","193.190.154.176/32"]
  }

  egress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["84.195.18.71/32","84.194.49.69/32","193.190.154.173/32","193.190.154.174/32","193.190.154.175/32","193.190.154.176/32"]
  }
}

resource "aws_security_group" "database_security_group" {
  name = "Database"
  description = "The security group of the database"
  vpc_id = aws_default_vpc.default.id

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = [aws_security_group.webserver_security_group.id]
  }

  egress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = [aws_security_group.webserver_security_group.id]
  }
}

module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "webserverdb"
  username = "webserverdb"
  password = "JensThomas05"
  port = 3306

  instance_class = "db.t3.small"
  engine = "mysql"
  engine_version = "5.7.19"
  major_engine_version = "5.7"
  family = "mysql5.7"
  allocated_storage = 5

  backup_window = "03:00-06:00"
  maintenance_window = "Mon:00:00-Mon:03:00"

  subnet_ids = data.aws_subnet_ids.default_subnet_id.ids
}

resource "tls_private_key" "webserver_private_key" {
  algorithm = "RSA"
}

module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"
  key_name   = "Webserver"
  public_key = tls_private_key.webserver_private_key.public_key_openssh
}

resource "local_file" "key_file" {
  content = tls_private_key.webserver_private_key.private_key_pem
  filename = "Webserver.pem"
}

#####################################################################
# OUTPUT
#####################################################################

output "this_db_instance_address" {
  description = "The address of the RDS instance"
  value = module.db.this_db_instance_address
}