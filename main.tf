provider "aws" {
  region = var.region
}

variable region {}
variable vpc_cidr {}
variable subnet_cidr {}
variable instance_type {}
variable ami {}

resource "aws_vpc" "my-vpc" {
  cidr_block = var.vpc_cidr


  tags = {
    Name = "nawaz-vpc"
  }
}

resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.my-vpc.id
  cidr_block        = var.subnet_cidr
  availability_zone = "ap-south-1a"

  tags = {
    Name = "main-subnet"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "main-igw"
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "main-route-table"
  }
}

resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

resource "aws_security_group" "nawaz-sg" {
  vpc_id = aws_vpc.my-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "main-sg"
  }
}

resource "aws_instance" "main" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.main.id
  availability_zone      = "ap-south-1a"
  vpc_security_group_ids = [aws_security_group.nawaz-sg.id]

  associate_public_ip_address = true
  key_name                    = "Terraform-key"

  tags = {
    Name = "Nawaz-instance"
  }
}


output "instance_id" {
  value = aws_instance.main.id
}
