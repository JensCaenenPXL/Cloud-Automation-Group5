#####################################################################
# VARIABLES
#####################################################################

variable "aws_access_key" {
  type    = string
  default = "ASIA5547CE7REJWYQSWL"
}
variable "aws_secret_key" {
  type    = string
  default = "07zd7kdKcgaLYYgTHEjR33iDgwAb34dX2YH3kBaG"
}

variable "aws_session_token" {
  type    = string
  default = "FwoGZXIvYXdzEE8aDAgPb3Wps15LXiXygyKuAaizvUTAOPls1jfOXwpCUuc4zPFHfpqrWGcE2rkkls8ES6qJhWYQQ5Ypwm6i/O98AE6olDEnZ5fFGZza9ib3uLecfCs0L/Gl4ZIieLOaRxwdMS5716TaFvEil4HNSg5aQtj76QzObQVy+OM2U2WM1TQU3DK/eju5+OPI3FxePm7UuQxlI8N8WUNnUk4oiOu6r7SISbVLkzTaPol0nFbvoEHLFNZT9l2a2X1C/LjQHyiK093+BTItqeLjQpu1DmUEH9rzPYa9eGuWqMJZD3nFEOnBRhRageOD5sbpMT5/30nG/Uxt"
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

resource "aws_security_group" "packer_security_group" {
  name        = "Packer"
  description = "The security group of the packer builder"
  vpc_id      = aws_default_vpc.default.id
}

resource "aws_security_group" "webserver_security_group" {
  name        = "Webserver"
  description = "The security group of all of the webservers"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.packer_security_group.id]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.packer_security_group.id]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.packer_security_group.id]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.packer_security_group.id]
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
    security_groups = [aws_security_group.webserver_security_group.id,aws_security_group.packer_security_group.id]
  }

  egress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.webserver_security_group.id,aws_security_group.packer_security_group.id]
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

resource "aws_security_group_rule" "packer_security_group_edit1" {
  type = "ingress"
  from_port       = 22
  to_port         = 22
  protocol        = "tcp"
  cidr_blocks = ["84.194.49.69/32","84.195.18.71/32"]
  security_groups = [aws_security_group.webserver_security_group.id,aws_security_group.database_security_group.id]
  depends_on = [
    aws_security_group.packer_security_group,
  ]
}

resource "aws_security_group_rule" "packer_security_group_edit2" {
  type = "egress"
  from_port       = 22
  to_port         = 22
  protocol        = "tcp"
  cidr_blocks = ["84.194.49.69/32","84.195.18.71/32"]
  security_groups = [aws_security_group.webserver_security_group.id,aws_security_group.database_security_group.id]
  depends_on = [
    aws_security_group.packer_security_group,
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
resource "aws_s3_bucket_object" "image4" {
  bucket = aws_s3_bucket.bucket.id
  key    = "jenkins.jpg"
  source = "./images/jenkins.jpg"
  etag = filemd5("./images/jenkins.jpg")
  acl = "public-read"
}

#####################################################################
# PACKER
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



resource "local_file" "packer_json" {
  content  = <<-DOC
    {
    "builders": [{
        "type": "amazon-ebs",
        "access_key": "${var.aws_access_key}",
        "secret_key": "${var.aws_secret_key}",
        "token": "${var.aws_session_token}",
        "region": "${var.region}",
        "source_ami": "ami-00ddb0e5626798373",
        "instance_type": "t2.micro",
        "ssh_username": "ubuntu",
        "ami_name": "Webserver",
        "security_group_id": "${aws_security_group.packer_security_group.id}",
        "force_deregister": true
    }],
    "provisioners": [
        {
            "type": "file",
            "source": "./ansible",
            "destination": "./"
        },  
        {
            "type": "shell",
            "inline": [
                "sudo apt update",
                "sudo apt install software-properties-common -y",
                "sudo apt-add-repository --yes --update ppa:ansible/ansible",
                "sudo apt install ansible -y",
                "sudo apt install git -y",
                "ansible-playbook ./ansible/plays/webserver.yml"
            ]  
        }
    ]
}
    DOC
  filename = "./packer.json"
  depends_on = [
    module.db,
  ]
}

resource "null_resource" "run_packer" {
  provisioner "local-exec" {
    command = "packer build packer.json"
  }
  depends_on = [
    local_file.localhost_yml,
  ]
}

data "aws_ami" "aws-linux" {
  most_recent = true
  owners      = ["957574424546"]

  filter {
    name   = "name"
    values = ["Webserver"]
  }
  depends_on = [
    null_resource.run_packer,
  ]
}

resource "aws_elb" "webserver_loadbalancer" {
  name               = "Webserver-Loadbalancer"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  security_groups = [aws_security_group.webserver_security_group.id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  depends_on = [
    null_resource.run_packer,
  ]
}

resource "aws_launch_template" "webserver_launch_template" {
  name_prefix   = "webserver_launch_template"
  image_id      = data.aws_ami.aws-linux.id
  instance_type = "t2.micro"
  security_group_names = ["Webserver"]
  depends_on = [
    null_resource.run_packer,
  ]
}

resource "aws_autoscaling_group" "webserver_autoscaling_group" {
  availability_zones = ["us-east-1a"]
  desired_capacity   = 2
  max_size           = 3
  min_size           = 1
  load_balancers     = [aws_elb.webserver_loadbalancer.id]

  launch_template {
    id      = aws_launch_template.webserver_launch_template.id
    version = "$Latest"
  }
  depends_on = [
    null_resource.run_packer,
  ]
}