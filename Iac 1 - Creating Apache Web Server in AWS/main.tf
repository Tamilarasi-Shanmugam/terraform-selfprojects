#AWS provider
provider "aws" {
    region = var.region
}

#VPC
resource "aws_vpc" "app_vpc"{
    cidr_block = var.vpc_cidr
    tags = {
    Name = "app-vpc"
  }
}

#internet gateway
resource "aws_internet_gateway" "igw"{
    vpc_id = aws_vpc.app_vpc.id
    tags = {
    Name = "vpc_igw"
  }
}

#subnet
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.app_vpc.id
  cidr_block = var.public_subnet_cidr
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet"
  }
}

#route table
resource "aws_route_table" "public_rt"{
    vpc_id = aws_vpc.app_vpc.id
    route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public_rt"
  }
}

#route table association
resource "aws_route_table_association" "public_rt_asso" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}


resource "aws_instance" "web" {
  ami             = "ami-*****"  #replace AMI ID as per region
  instance_type   = var.instance_type
  subnet_id       = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.sg.id]

  user_data = <<-EOF
  #!/bin/bash
  echo "*** Installing httpd"
  sudo yum clean all
  sudo yum update -y
  sudo yum install -y httpd
  sudo systemctl start httpd
  sudo systemctl enable httpd
  sudo systemctl status httpd
  echo "*** Completed Installing httpd"
  EOF

  tags = {
    Name = "web_instance"
  }

  volume_tags = {
    Name = "web_instance"
  } 
}