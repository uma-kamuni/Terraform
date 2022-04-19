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

