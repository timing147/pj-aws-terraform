provider "aws" {
  region = "us-west-2"
}


# Creating VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.20.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true
  enable_dns_support = true


  tags = {
    Name = "VPC-subregion-oregon"
  }
}

# Creating Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "Sub-igw"
  }

  depends_on = [ aws_vpc.vpc ]
}

# Creating Public Subnet 1 for Web Tier Instance
resource "aws_subnet" "public-subnet1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.20.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "oregon-public-subnet1"
  }

  depends_on = [ aws_internet_gateway.igw ]
}


# Creating Private Subnet 1 for EC2 Instance
resource "aws_subnet" "private-subnet1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.20.2.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = false

  tags = {
    Name = "oregon-private-subnet1"
  }

  depends_on = [ aws_subnet.public-subnet1 ]
}


# Creating Private Subnet 3 for RDB Instance
resource "aws_subnet" "private-subnet2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.20.3.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = false

  tags = {
    Name = "oregon-private-subnet1"
  }

  depends_on = [ aws_subnet.private-subnet1 ]
}

# Creating Elastic IP for NAT Gateway 1
resource "aws_eip" "eip1" {
  domain = "vpc"

  tags = {
    Name = "eip-oregon1"
  }

  depends_on = [ aws_subnet.private-subnet2 ]
}

# Creating NAT Gateway 1
resource "aws_nat_gateway" "ngw1" {
  allocation_id = aws_eip.eip1.id
  subnet_id     = aws_subnet.public-subnet1.id

  tags = {
    Name = "nat-oregon1"
  }

  depends_on = [ aws_eip.eip1 ]
}

# Creating Public Route table 1
resource "aws_route_table" "public-rt1" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "rt-to-igw"
  }

  depends_on = [ aws_nat_gateway.ngw1 ]
}

# Associating the Public Route table 1 Public Subnet 1
resource "aws_route_table_association" "public-rt-association1" {
  subnet_id      = aws_subnet.public-subnet1.id
  route_table_id = aws_route_table.public-rt1.id

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
    Name = "rt-to-nat"
  }

  depends_on = [ aws_route_table_association.public-rt-association1 ]
}

# Associating the Private Route table 1 Private Subnet 1
resource "aws_route_table_association" "private-rt-association1" {
  subnet_id      = aws_subnet.private-subnet1.id
  route_table_id = aws_route_table.private-rt1.id

  depends_on = [ aws_route_table.private-rt1 ]
}

# Associating the Private Route table 2 Private Subnet 3
resource "aws_route_table_association" "private-rt-association2" {
  subnet_id      = aws_subnet.private-subnet2.id
  route_table_id = aws_route_table.private-rt1.id

  depends_on = [ aws_subnet.private-subnet2 ]
}

