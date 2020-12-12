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
# DATA
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