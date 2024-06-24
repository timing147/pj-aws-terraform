data "aws_ami" "ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["APP-image-kms-v1.1"]
  }

  owners = ["533266984569"] 
}

data "aws_security_group" "web-sg" {
  filter {
    name   = "tag:Name"
    values = [var.web-sg-name]
  }
}

data "aws_subnet" "public-subnet1" {
  filter {
    name   = "tag:Name"
    values = [var.public-subnet-name1]
  }
}

data "aws_subnet" "public-subnet2" {
  filter {
    name   = "tag:Name"
    values = [var.public-subnet-name2]
  }
}
/*
data "aws_lb_target_group" "tg" {
  tags = {
    Name = var.tg-name
  }
}
*/
data "aws_lb_target_group" "tg2" {
  tags = {
    Name = "App-TG-kms"
  }
}

data "aws_iam_instance_profile" "instance-profile" {
  name = var.instance-profile-name
}

data "aws_subnet" "private-subnet1" {
  filter {
    name   = "tag:Name"
    values = [var.private-subnet-name1]
  }
}

data "aws_subnet" "private-subnet2" {
  filter {
    name   = "tag:Name"
    values = [var.private-subnet-name2]
  }
}
/*
data "aws_key_pair" "key_name" {
  key_name           = "kms-keypair"
  include_public_key = true

  filter {
    name   = "tag:Name"
    values = ["kms-keypair"]
  }
}
*/
variable "aws_efs_file_system" {
  type    = string
  default = "kms-efs"
}

data "aws_efs_file_system" "efs" {
  
  tags = {
    Name = "kms-efs"
  }
}