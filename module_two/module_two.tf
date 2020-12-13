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
  image_id      = aws_ami.aws-linux.id
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
