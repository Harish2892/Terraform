provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}
#Backend configuration,create bucket n provide access key n secret key
terraform {
  backend "s3" {
    bucket     = "mystatefiles"
    key        = "terraform/state"
    region     = "us-east-2"
    access_key = "<enter_access_key"
    secret_key = "<enter_secret_key"
    #   dynamodb_table= "harish"
  }
}
#create a VPC
resource "aws_vpc" "Prod-iTS-Apps-VPC" {
  cidr_block           = var.cidr_block
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  tags                 = local.iTelaSoft
}
#create a Public Subnet
resource "aws_subnet" "Public-Subnet" {
  vpc_id                  = aws_vpc.Prod-iTS-Apps-VPC.id
  cidr_block              = var.Public-Subnet-Cidr
  map_public_ip_on_launch = "true"
  tags                    = local.iTelaSoft
}
#Create a Private Subnet
resource "aws_subnet" "Private-Subnet" {
  vpc_id     = aws_vpc.Prod-iTS-Apps-VPC.id
  cidr_block = var.Private-Subnet-Cidr
  tags       = local.iTelaSoft
}
#create a IGW and attach it to Public Subnet
resource "aws_internet_gateway" "Prod-iTS-IGW" {
  vpc_id = aws_vpc.Prod-iTS-Apps-VPC.id
  tags   = local.iTelaSoft
}
#create Route Table
resource "aws_route_table" "Prod-iTS-PublicRT" {
  vpc_id = aws_vpc.Prod-iTS-Apps-VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Prod-iTS-IGW.id
  }
  tags = local.iTelaSoft
}
#Public Subnet Association
resource "aws_route_table_association" "Prod-iTS-PublicSA" {
  subnet_id      = aws_subnet.Public-Subnet.id
  route_table_id = aws_route_table.Prod-iTS-PublicRT.id
}

#Create Elastic IP to attach it to NAT
resource "aws_eip" "Prod-iTS-EIP" {
  vpc  = true
  tags = local.iTelaSoft
}
#Create NAT Gateway
resource "aws_nat_gateway" "Prod-iTS-NAT" {
  allocation_id = aws_eip.Prod-iTS-EIP.id
  subnet_id     = aws_subnet.Public-Subnet.id
  tags          = local.iTelaSoft
}
#create a Private Route Table and attach NATGateway
resource "aws_route_table" "Prod-iTS-PrivateRT" {
  vpc_id = aws_vpc.Prod-iTS-Apps-VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.Prod-iTS-NAT.id
  }
  tags = local.iTelaSoft
}
#Subnet and Route Table Association
resource "aws_route_table_association" "Prod-iTS-PrivsteSA" {
  subnet_id      = aws_subnet.Private-Subnet.id
  route_table_id = aws_route_table.Prod-iTS-PrivateRT.id
}
#Create a Security Group for EC2
resource "aws_security_group" "Prod-iTS-WebserverSG" {
  name        = "Prod-iTS-WebserverSG"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.Prod-iTS-Apps-VPC.id
  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "TLS from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = local.iTelaSoft
}
#create key-pair for EC2
resource "aws_key_pair" "webserverkey" {
  key_name   = "webserverkey"
  public_key = var.public_key
}
#Create EC2 in Public subnet
resource "aws_instance" "webserver" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.Public-Subnet.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.webserverkey.id
  vpc_security_group_ids      = [aws_security_group.Prod-iTS-WebserverSG.id]
  tags                        = local.iTelaSoft
}
#create EC2 in Private Subnet
resource "aws_instance" "dbserver" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.Private-Subnet.id
  vpc_security_group_ids = [aws_security_group.Prod-iTS-WebserverSG.id]
  key_name               = aws_key_pair.webserverkey.id
  tags                   = local.iTelaSoft
}
