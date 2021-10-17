variable "region" {
  type = string
}
variable "access_key" {
  type = string
}
variable "secret_key" {
  type = string
}
variable "cidr_block" {
  type = string
}

#to give the tags to each resource
locals {
  iTelaSoft = {
    Service           = "VPC"
    Environment       = "Prod"
    Project           = "iTS-Internal"
    "Project Manager" = "Harish"
    Owner             = "Harish"
    Client            = "iTS-Internal"
    "Cost Center"     = "iTelaSoft"
  }
}

variable "Public-Subnet-Cidr" {
  type = string
}

variable "Private-Subnet-Cidr" {
  type = string
}

variable "public_key" {
  type = string

}

variable "instance_type" {
  type = string
}

variable "ami" {
  type = string
}