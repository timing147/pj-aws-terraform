resource "aws_instance" "ec2" {
  ami = "ami-09cfb54df900806e2"
  instance_type = "t3.micro"
  tags = {
    Name = "dev-instance"
    Owner = "kms"
    CreateDate = formatdate("YYYY-MM-DD", timestamp())
  }
}
