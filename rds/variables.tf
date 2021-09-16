variable "name" {
  description = "the name of your stack, e.g. \"demo\""
}

variable "environment" {
  description = "the name of your environment, e.g. \"prod\""
}

variable "instance_class" {
  description = "Cluster instance class"
}

variable "vpc_id" {
  description = "The VPC the cluser should be created in"
}

variable "private_subnets" {
  description = "List of private subnet IDs"
}

variable "public_subnets" {
  description = "List of private subnet IDs"
}

variable "cidr_block" {
  description = "List of CIDR block"
}

variable "db_subnet_group_id" {
  description = "Subnet Group ID"
}

variable "rds_user_name" {
  description = "List of CIDR block"
}

variable "rds_user_password" {
  description = "Subnet Group ID"
}