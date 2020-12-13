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

#####################################################################
# RESOURCES
#####################################################################

resource "aws_launch_template" "webserver_launch_template" {
  name_prefix   = "webserver_launch_template"
  image_id      = data.aws_ami.aws-linux.id
  instance_type = "t2.micro"
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

