
provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "terra-vpc" {
  cidr_block       = "10.0.0.0/16"
 enable_dns_hostnames = "true"

  tags = {
    Name = "terra-vpc"
  }
}

resource "aws_internet_gateway" "terra-igw" {
  vpc_id = aws_vpc.terra-vpc.id

  tags = {
    Name = "terra-igw"
  }
}

resource "aws_subnet" "terra-pub-subnet" {
  vpc_id     = aws_vpc.terra-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "terra-pub-subnet"
  }
}

resource "aws_subnet" "terra-priv-subnet" {
  vpc_id     = aws_vpc.terra-vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "terra-priv-subnet"
  }
}


resource "aws_route_table" "terra-pub-rt" {
  vpc_id = aws_vpc.terra-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terra-igw.id
  }
  tags = {
    Name = "terra-pub-rt"
  }
}

resource "aws_route_table_association" "terra-pub-rta" {
  subnet_id      = aws_subnet.terra-pub-subnet.id
  route_table_id = aws_route_table.terra-pub-rt.id
}

resource "aws_eip" "priv-eip" {
  vpc = true
}

resource "aws_nat_gateway" "terra-nat" {
  allocation_id = aws_eip.priv-eip.id
  subnet_id     = aws_subnet.terra-pub-subnet.id

  tags = {
    Name = "terra-pub-nat"
  }
}

resource "aws_route_table" "terra-priv-rt" {
  vpc_id = aws_vpc.terra-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.terra-nat.id
  }
  tags = {
    Name = "terra-priv-rt"
  }
}

resource "aws_route_table_association" "terra-priv-rta" {
  subnet_id      = aws_subnet.terra-priv-subnet.id
  route_table_id = aws_route_table.terra-priv-rt.id
}

resource "aws_security_group" "terra-sg" {
  name        = "allow_all"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.terra-vpc.id

  tags = {
    Name = "allow_all"
  }

    ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
     }

    egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
     }
       tags = {
    Name = "terra-sg"
  }
}