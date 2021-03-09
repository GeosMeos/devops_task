variable "region" {
  description = "us-east-1"
}

variable "environment" {
  description = "The Deployment environment"
}

variable "vpc_cidr" {
  description = "The CIDR block of the vpc"
}

variable "public_subnets_cidr" {
  type        = list
  description = "The CIDR block for the public subnet"
}

variable "private_subnets_cidr" {
  type        = list
  description = "The CIDR block for the private subnet"
}

variable "ami_id" {
  description = "The ami id to use for lamp stack"
}

variable "win_ami_id" {
  description = "The ami id to use for windows server machine"
}

variable "instance_type" {
  description = "The instance type to use"
}

variable "key_name" {
  description = "The key-pair to use for ssh"
}