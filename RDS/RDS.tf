provider "aws" { profile = "default" }

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
