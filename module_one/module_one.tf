#####################################################################
# VARIABLES
#####################################################################

variable "aws_access_key" {
  type    = string
  default = "ASIA5547CE7ROUUGKTRR"
}
variable "aws_secret_key" {
  type    = string
  default = "VTRzqPkMUb+AS/8cYHPy51o/Zm1zRyA8faYrafi6"
}

variable "aws_session_token" {
  type    = string
  default = "FwoGZXIvYXdzEDoaDJhzWG2mKihUBFMs+iKuAaErWWQPFxTkFtUe1EXjd5ZJqHN6r2qaRnXGDawGNwFfdNZXXxsK1KdS0iR1ID22KBGrU2CVhHZ4tfVkxCYWKcZJlM0CrAB3LDvFXEB29gP+Hm3QnAqjdOlKmpSJMkGJLMZU/6Q7YgN2jnzquQ2CcKcQnyJZYx7uPWikNLaKI20IbSfWsMXBmGoMNyjhWd3Os/ePfZey5wKg8r9vVsf8LL/wlxFb0x9vu8wcbiongyjkjNn+BTItHm1EDfcq5jS0OIGMCHFyduWwei9Z6ZrCQT4OM3SQAQLWzkPnmaKvgO4brLmo"
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

data "aws_ami" "aws-linux" {
  most_recent = true
  owners      = ["957574424546"]

  filter {
    name   = "name"
    values = ["Webserver"]
  }
}

data "aws_security_group" "webserver_security_group" {
  filter {
    name   = "name"
    values = ["Webserver"]
  }
}

#####################################################################
# RESOURCES
#####################################################################

resource "aws_elb" "webserver_loadbalancer" {
  name               = "Webserver-Loadbalancer"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  instances                   = [aws_instance.foo.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400
}

resource "aws_launch_template" "webserver_launch_template" {
  name_prefix   = "webserver_launch_template"
  image_id      = data.aws_ami.aws-linux.id
  instance_type = "t2.micro"
  vpc_security_group_ids = data.aws_security_group.webserver_security_group.id
}

resource "aws_autoscaling_group" "webserver_autoscaling_group" {
  availability_zones = ["us-east-1a"]
  desired_capacity   = 2
  max_size           = 3
  min_size           = 1

  launch_template {
    id      = aws_launch_template.webserver_launch_template.id
    version = "$Latest"
  }
}

