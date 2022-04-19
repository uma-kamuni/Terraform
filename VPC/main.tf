resource "aws_vpc" "myvpc" {
  cidr_block    = "10.0.0.0/26"
  instance_tenancy = "default"
  tags = {
    Name = "myvpc"
    }
}


resource "aws_subnet" "publicsubnet" {
  vpc_id = aws_vpc.myvpc.id
  cidr_block    = "10.0.0.0/28"
  availability_zone = "us-east-1a"
  tags = {
    Name = "publicsubnet"
    }
}


resource "aws_subnet" "privatesubnet" {
  vpc_id = aws_vpc.myvpc.id
  cidr_block   = "10.0.0.16/28"
  availability_zone = "us-east-1b"
  tags = {
    Name = "privatesubnet"
    }
}


resource "aws_internet_gateway" "myIGW" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "myIGW"
    }
}


resource "aws_route_table" "publicRT" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "publicRT"
    }
      route {
  cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.myIGW.id
  }
}


resource "aws_route_table" "privateRT" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "privateRT"
    }
      route {
  cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.NATgw.id
  }
}


resource "aws_route_table_association" "publicRTassociation" {
  subnet_id       = aws_subnet.publicsubnet.id
  route_table_id  = aws_route_table.publicRT.id
}


resource "aws_route_table_association" "privateRTassociation" {
  subnet_id       = aws_subnet.privatesubnet.id
  route_table_id  = aws_route_table.privateRT.id
}


resource "aws_eip" "natEIP" {
  vpc = true
}


resource "aws_nat_gateway" "NATgw" {
  allocation_id = aws_eip.natEIP.id
  subnet_id = aws_subnet.publicsubnet.id
  tags = {
    Name = "NATgw"
    }
}
