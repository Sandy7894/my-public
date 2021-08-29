variable "aws_region" {
  default = "us-west-2"
}

variable "account_id" {
  default = "782061671862"
}

variable "profile_name" {
  type = string
  default = "Terraform"
}

variable "cidr" {
  default = "10.0.0.0/16"
}

variable "internet_network" {
  default = "0.0.0.0/0"
}

variable "zones" {
  type    = list(string)
  default = ["b","c"]
}

variable "vpc_id" {
  default = "vpc-0d555b83ee6aad3a5"
}

variable ami_id {
  default = "ami-083ac7c7ecf9bb9b0"
}

variable "instance_type" {
  default = "t2.micro"
}
