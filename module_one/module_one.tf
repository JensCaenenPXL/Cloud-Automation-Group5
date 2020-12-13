#####################################################################
# VARIABLES
#####################################################################

variable "aws_access_key" {
  type    = string
  default = "ASIA5547CE7RK4UO6EVG"
}
variable "aws_secret_key" {
  type    = string
  default = "W3me3sVucltJ8/OWOX/61YSfO8rYA/klN91Ri/fq"
}

variable "aws_session_token" {
  type    = string
  default = "FwoGZXIvYXdzEDgaDENhuTVJ+t4syTmMLiKuAfsH/HL3pKO/9cNCGpXg9go8mC2UTT04rmoGMu4fZz8HLKK5Ry40HQT8T8QmPBSeIQJzXuhMi6suuNUrzVucig8g/kbSGnHIrq5nHqQ5XcBbSwkyY6Vk2sPpnXXWbLfBb4CNq01O8wi0jQznPZekaA1C1igFHdE2TJxOItDxxdFcmevdKZ0T5oVdtLdB96AfTkiO6Gqb9Qf5js+wqtIYSZkKQB+yR2E03Z7rj19WsCiqxdj+BTItlBFRwl1Wv9pMLPzo89L1SsWLbb0Nf4uKAbEuWut6OvBZ8tCvBSpduY3W8AZK"
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

