# Creating ALB for App Tier
resource "aws_lb" "app-elb" {

  #depends_on = [ aws_lb.web-elb ]

  name = var.alb-name
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.public-subnet1.id, aws_subnet.public-subnet2.id]
  security_groups    = [aws_security_group.alb-sg.id]
  ip_address_type    = "ipv4"
  enable_deletion_protection = false

  tags = {
    Name = var.alb-name
    Owner = var.Owner
    CreateDate = formatdate("YYYY-MM-DD", timestamp())
    }
}

# Creating Target Group for App-Tier 
resource "aws_lb_target_group" "app-tg" {
  name = var.tg-name

  health_check {
    enabled = true
    interval            = 10
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
  target_type = "instance"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  tags = {
    Name = var.tg-name
    Owner = var.Owner
    CreateDate = formatdate("YYYY-MM-DD", timestamp())
  } 

  lifecycle {
    prevent_destroy = false
  } 
  depends_on = [ aws_lb.app-elb ]
}

# Creating ALB listener with port 80 and attaching it to App-Tier Target Group
resource "aws_lb_listener" "app-alb-listener" {
  load_balancer_arn = aws_lb.app-elb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app-tg.arn
  }

  depends_on = [ aws_lb_target_group.app-tg ]
}