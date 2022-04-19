resource "aws_instance" "terraform-ec2" {
  ami            = "ami-04505e74c0741db8d"
  instance_type  = "t2.micro"
  key_name       = "aws-demo"
  tags = {
    Name = "terraform-ec2"
  }
}
