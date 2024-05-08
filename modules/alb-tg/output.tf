output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = try(aws_lb.web-elb.dns_name)
}