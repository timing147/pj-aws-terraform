data "aws_subnet" "private-subnet3" {
  filter {
    name   = "tag:Name"
    values = [var.private-subnet-name3]
  }
}

data "aws_subnet" "private-subnet4" {
  filter {
    name   = "tag:Name"
    values = [var.private-subnet-name4]
  }
}

data "aws_security_group" "db-sg" {
  filter {
    name   = "tag:Name"
    values = [var.db-sg-name]
  }
}