#####################################################################
# VARIABLES
#####################################################################

variable "aws_access_key" {
  default = "ASIA5547CE7RP3YU43X3"
}
variable "aws_secret_key" {
  default = "Jt/Ler+uhxdKwgLrZ3R4ND9yn93UJNnvZsH5J/yM"
}

variable "aws_session_token" {
  default = "FwoGZXIvYXdzEBUaDNkrvdQPnSRxsW3l8iKuAQVCJBJVfX6+q8y1yX9lJUSI/8ZgLzALz4ip+IhE8W9bdxtfWTwRUCabvpJn7jVXtOtv4IMXv2yHvOriaEBpo4MBo8b+eK1Ge+4TZieFEVPADGPXzT0ujTD22m7Vn2xKjUwz50jt+o79yaYQRHx1usPh5xT6/mXeFoZEejngJ5ayr1H3/eRXp+9fDs+RCSHkClCJKIgyh7Kj+V7WuP/fw1SG6/to4OVhTDMoKZoHYCiT3pj+BTItzkloOZk+RHo6ju2iqyRYYoyvYUkehbZqsXAs5Ae80iKrBaU7UPGawSjeROSV"
}

variable "private_key_path" {
  default = "C:\\Users\\Jens Caenen\\.ssh\\id_rsa"
}

variable "region" {
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
# PROVIDERS
#####################################################################

data "aws_ami" "aws-linux" {
  most_recent = true
  owners = ["957574424546"]

  filter {
    name = "name"
    values = ["Webserver"]
  }
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
}

resource "aws_instance" "webserver1" {
  ami = data.aws_ami.aws-linux.id
  instance_type = "t2.micro"
  key_name = "Webserver"
  vpc_security_group_ids = [aws_security_group.webserver_security_group.id]

  connection {
    type = "ssh"
    host = self.public_ip
    user = "ec2-user"
    private_key = file(var.private_key_path)
  }
}

#####################################################################
# OUTPUT
#####################################################################
output "aws_instance_public_dns" {
    value = aws_instance.webserver1.public_dns
}
