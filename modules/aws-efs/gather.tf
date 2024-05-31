data "aws_security_group" "efs-sg" {
  filter {
    name   = "tag:Name"
    values = [var.efs-sg-name]
  }
}

data "aws_subnet" "private-subnet1" {
  filter {
    name = "tag:Name"
    values = [var.private-subnet-name1]
  }
}

data "aws_subnet" "private-subnet2" {
  filter {
    name = "tag:Name"
    values = [var.private-subnet-name2]
  }
}