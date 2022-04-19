  GNU nano 4.8                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              codeinfrastructure.tf
resource "aws_instance" "terraform-ec2" {
  ami            = "ami-04505e74c0741db8d"
  instance_type  = "t2.micro"
  key_name       = "aws-demo"
  tags = {
    Name = "terraform-ec2"
  }
}


resource "aws_db_instance" "default" {
  allocated_storage    = 8
  engine               = "mysql"
  engine_version       = "8.0.27"
  instance_class       = "db.t3.micro"
  db_name              = "mysqldb"
  username             = "uma"
  password             = "umakamuni"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = false
}



resource "aws_s3_bucket" "my-s3-bucket" {
  bucket_prefix = var.bucket_prefix
  acl = var.acl

   versioning {
    enabled = var.versioning
  }

  tags = var.tags
}



variable "bucket_prefix" {
    type        = string
    description = "Creates a unique bucket name beginning with the specified prefix."
    default     = "my-s3bucket-"
}

variable "tags" {
    type        = map
    description = "(Optional) A mapping of tags to assign to the bucket."
    default     = {
        environment = "DEV"
        terraform   = "true"
    }
}

variable "versioning" {
    type        = bool
    description = "(Optional) A state of versioning."
    default     = true
}

variable "acl" {
    type        = string
    description = " Defaults to private "
    default     = "private"
}




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



resource "aws_security_group" "httpssh" {
    vpc_id = aws_vpc.myvpc.id

    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "httpssh"
    }
}

resource "aws_instance" "publicEC2" {
  ami                            = "ami-04505e74c0741db8d"
  instance_type                  = "t2.micro"
  associate_public_ip_address    = "true"
  key_name                       = "aws-demo"
  vpc_security_group_ids         = [aws_security_group.httpssh.id]
  subnet_id                      = aws_subnet.publicsubnet.id
  tags = {
    Name = "publicEC2"
  }
}



resource "aws_instance" "privateEC2" {
  ami                            = "ami-04505e74c0741db8d"
  instance_type                  = "t2.micro"
  associate_public_ip_address    = "false"
  key_name                       = "aws-demo"
  vpc_security_group_ids         = [aws_security_group.httpssh.id]
  subnet_id                      = aws_subnet.privatesubnet.id
  tags = {
    Name = "privateEC2"
    }
}



