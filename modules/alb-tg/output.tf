output "app-alb-dns" {
  description = "App tier DNS name"
  value = try(aws_lb.app-elb.dns_name)
}