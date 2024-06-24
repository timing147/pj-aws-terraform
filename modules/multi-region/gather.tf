data "aws_ami" "ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["APP-image-kms-v1.1"]
  }

  owners = ["533266984569"] 
}
