resource "aws_security_group" "alb-sg" {
  vpc_id      = data.aws_vpc.vpc.id
  description = "Allow HTTP and HTTPS for World"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = var.alb-sg-name
    Owner = var.Owner
    CreateDate = formatdate("YYYY-MM-DD", timestamp())
  }

  depends_on = [ data.aws_vpc.vpc ]
}


resource "aws_security_group" "web-tier-sg" {
  vpc_id      = data.aws_vpc.vpc.id
  description = "Allow HTTP and HTTPS for ALB Only"
/*  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
*/
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb-sg.id]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = var.web-sg-name
    Owner = var.Owner
    CreateDate = formatdate("YYYY-MM-DD", timestamp())
  }

  depends_on = [ aws_security_group.alb-sg ]
}


# Creating Security Group for RDS Instances Tier With  only access to App-Tier ALB
resource "aws_security_group" "database-sg" {
  vpc_id      = data.aws_vpc.vpc.id
  description = "Protocol Type MySQL/Aurora"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web-tier-sg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = var.db-sg-name
    Owner = var.Owner
    CreateDate = formatdate("YYYY-MM-DD", timestamp())
  }

  depends_on = [ aws_security_group.web-tier-sg ]
}

# Creating Security Group for EFS With  only access to App-Tier Instance
resource "aws_security_group" "efs-sg" {
  vpc_id      = data.aws_vpc.vpc.id
  description = "Allow NFS"

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = var.efs-sg-name
    Owner = var.Owner
    CreateDate = formatdate("YYYY-MM-DD", timestamp())
  }

  depends_on = [ aws_security_group.database-sg ]
}