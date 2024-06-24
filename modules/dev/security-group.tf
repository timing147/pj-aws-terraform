resource "aws_security_group" "alb-sg" {
  vpc_id      = aws_vpc.vpc.id
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

  tags = merge(
    {Name = "dev-alb-sg"}, local.common-tags
  )

  depends_on = [ aws_vpc.vpc ]
}


resource "aws_security_group" "web-tier-sg" {
  vpc_id      = aws_vpc.vpc.id
  description = "Allow HTTP and HTTPS for ALB Only"

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

  tags = merge(
    {Name = "dev-web-sg"}, local.common-tags
  )

  depends_on = [ aws_security_group.alb-sg ]
}



