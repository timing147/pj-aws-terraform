output "main_vpc_id" {
  value = aws_vpc.vpc.id
}
output "main_vpc_cidr_block" {
  value = aws_vpc.vpc.cidr_block
}
output "main_rt1_id" {
  value = aws_route_table.private-rt1.id
}

output "main_rt2_id" {
  value = aws_route_table.private-rt2.id
}
