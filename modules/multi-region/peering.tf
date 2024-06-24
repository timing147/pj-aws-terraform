
resource "aws_vpc_peering_connection" "peering" {
  peer_vpc_id   = var.main_vpc_id
  vpc_id        = aws_vpc.vpc.id
  peer_region   = "ap-southeast-1"
 
}

resource "aws_vpc_peering_connection_accepter" "name" {
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
  provider = aws.ap-southeast-1
  auto_accept = true

  tags = {
  Name = "peer-singapore-to-oregon"
  Owner = var.Owner
  CreateDate = formatdate("YYYY-MM-DD", timestamp())
  } 
}


resource "aws_route" "rt_peer1" {
  route_table_id = aws_route_table.private-rt1.id
  destination_cidr_block = var.main_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
}



resource "aws_route" "rt_peer2" {
  provider = aws.ap-southeast-1
  route_table_id = var.main_rt_1_id
  destination_cidr_block = aws_vpc.vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
}

resource "aws_route" "rt_peer3" {
  provider = aws.ap-southeast-1
  route_table_id = var.main_rt_2_id
  destination_cidr_block = aws_vpc.vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
}