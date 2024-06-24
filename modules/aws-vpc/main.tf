# Creating VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc-cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true
  enable_dns_support = true


  tags = {
    Name = var.vpc-name
  }
}

# Creating Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = var.igw-name
  }

  depends_on = [ aws_vpc.vpc ]
}

# Creating Public Subnet 1 for Web Tier Instance
resource "aws_subnet" "public-subnet1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public-cidr1
  availability_zone       = var.az-1
  map_public_ip_on_launch = true

  tags = {
    Name = var.public-subnet1
  }

  depends_on = [ aws_internet_gateway.igw ]
}

# Creating Public Subnet 2 for Web Tier Instance
resource "aws_subnet" "public-subnet2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public-cidr2
  availability_zone       = var.az-2
  map_public_ip_on_launch = true

  tags = {
    Name = var.public-subnet2
  }

  depends_on = [ aws_subnet.public-subnet1 ]
}

# Creating Private Subnet 1 for EC2 Instance
resource "aws_subnet" "private-subnet1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private-cidr1
  availability_zone       = var.az-1
  map_public_ip_on_launch = false

  tags = {
    Name = var.private-subnet1
  }

  depends_on = [ aws_subnet.public-subnet2 ]
}

# Creating Private Subnet 2 for EC2 Instance
resource "aws_subnet" "private-subnet2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private-cidr2
  availability_zone       = var.az-2
  map_public_ip_on_launch = false

  tags = {
    Name = var.private-subnet2
  }

  depends_on = [ aws_subnet.private-subnet1 ]
}

# Creating Private Subnet 3 for RDB Instance
resource "aws_subnet" "private-subnet3" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private-cidr3
  availability_zone       = var.az-1
  map_public_ip_on_launch = false

  tags = {
    Name = var.private-subnet3
  }

  depends_on = [ aws_subnet.private-subnet2 ]
}

# Creating Private Subnet 4 for RDB Instance
resource "aws_subnet" "private-subnet4" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private-cidr4
  availability_zone       = var.az-2
  map_public_ip_on_launch = false

  tags = {
    Name = var.private-subnet4
  }

  depends_on = [ aws_subnet.private-subnet3 ]
}

# Creating Elastic IP for NAT Gateway 1
resource "aws_eip" "eip1" {
  domain = "vpc"

  tags = {
    Name = var.eip-name1
  }

  depends_on = [ aws_subnet.private-subnet4 ]
}
/*
# Creating Elastic IP for NAT Gateway 2
resource "aws_eip" "eip2" {
  domain = "vpc"

  tags = {
    Name = var.eip-name2
  }

  depends_on = [ aws_eip.eip1 ]
}
*/
# Creating NAT Gateway 1
resource "aws_nat_gateway" "ngw1" {
  allocation_id = aws_eip.eip1.id
  subnet_id     = aws_subnet.public-subnet1.id

  tags = {
    Name = var.ngw-name1
  }

  depends_on = [ aws_eip.eip1 ]
}

# Creating NAT Gateway 2
#resource "aws_nat_gateway" "ngw2" {
#  allocation_id = aws_eip.eip2.id
#  subnet_id     = aws_subnet.public-subnet2.id

#  tags = {
##    Name = var.ngw-name2
#  }

#  depends_on = [ aws_nat_gateway.ngw1 ]
#}

# Creating Public Route table 1
resource "aws_route_table" "public-rt1" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = var.public-rt-name1
  }

  depends_on = [ aws_nat_gateway.ngw1 ]
}

# Associating the Public Route table 1 Public Subnet 1
resource "aws_route_table_association" "public-rt-association1" {
  subnet_id      = aws_subnet.public-subnet1.id
  route_table_id = aws_route_table.public-rt1.id

  depends_on = [ aws_route_table.public-rt1 ]
}

# Creating Public Route table 2 
resource "aws_route_table" "public-rt2" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = var.public-rt-name2
  }
  
  depends_on = [ aws_route_table_association.public-rt-association1 ]
}

# Associating the Public Route table 2 Public Subnet 2
resource "aws_route_table_association" "public-rt-association2" {
  subnet_id      = aws_subnet.public-subnet2.id
  route_table_id = aws_route_table.public-rt2.id

  depends_on = [ aws_route_table.public-rt1 ]
}


# Creating Private Route table 1
resource "aws_route_table" "private-rt1" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw1.id
  }

  tags = {
    Name = var.private-rt-name1
  }

  depends_on = [ aws_route_table_association.public-rt-association2 ]
}

# Associating the Private Route table 1 Private Subnet 1
resource "aws_route_table_association" "private-rt-association1" {
  subnet_id      = aws_subnet.private-subnet1.id
  route_table_id = aws_route_table.private-rt1.id

  depends_on = [ aws_route_table.private-rt1 ]
}

# Creating Private Route table 2 (nat 1개로 변경중 )
resource "aws_route_table" "private-rt2" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw1.id
  }

  tags = {
    Name = var.private-rt-name2
  }

  depends_on = [ aws_route_table_association.private-rt-association1 ]
}

# Associating the Private Route table 2 Private Subnet 2
resource "aws_route_table_association" "private-rt-association2" {
  subnet_id      = aws_subnet.private-subnet2.id
  route_table_id = aws_route_table.private-rt2.id

  depends_on = [ aws_route_table.private-rt2 ]
}

# Associating the Private Route table 2 Private Subnet 3
resource "aws_route_table_association" "private-rt-association3" {
  subnet_id      = aws_subnet.private-subnet3.id
  route_table_id = aws_route_table.private-rt1.id

  depends_on = [ aws_subnet.private-subnet3 ]
}

# Associating the Private Route table 2 Private Subnet 3
resource "aws_route_table_association" "private-rt-association4" {
  subnet_id      = aws_subnet.private-subnet4.id
  route_table_id = aws_route_table.private-rt2.id

  depends_on = [ aws_subnet.private-subnet4 ]
}

# ec2 instance connect endpoint
resource "aws_ec2_instance_connect_endpoint" "endpoint" {
  subnet_id = aws_subnet.public-subnet1.id
}
/*
# vpc flow log

data "aws_iam_policy_document" "flow_logs_policy" {
  source_policy_documents = [file("${path.module}/kms-flowlog-policy.json")]
}
# file("${path.module}
resource "aws_iam_policy" "flow_logs_policy" {
  name        = "flow-logs-policy"
  policy      = data.aws_iam_policy_document.flow_logs_policy.json
}

resource "aws_iam_role" "flow_logs_role" {
  name               = "flow-logs-role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "flow_logs_policy_attachment" {
  policy_arn = aws_iam_policy.flow_logs_policy.arn
  role       = aws_iam_role.flow_logs_role.name
}

# VPC Flow Logs
resource "aws_flow_log" "flowlog" {
  log_destination      = aws_cloudwatch_log_group.flowlog-group.arn
  traffic_type         = "ALL"
  log_destination_type = "cloud-watch-logs"
  iam_role_arn         = aws_iam_role.flow_logs_role.arn
  vpc_id               = aws_vpc.vpc.id
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "flowlog-group" {
  name              = "vpc-flow-logs"
  retention_in_days = 14
}

*/