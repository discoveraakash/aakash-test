variable "domain" {
  description = "the name of your eleasticSearch Domain, e.g. \"prod\""
}

variable "environment" {
  description = "the name of your environment, e.g. \"prod\""
}

variable "name" {
  description = "the name of your stack, e.g. \"demo\""
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

variable "vpc_cidr_blocks" {
  description = "VPC CIDR Block"
}

variable "master_user_name" {
  description = "Elastic Search master username, e.g. \"prod\""
}

variable "master_user_password" {
  description = "Elastic Search master password, e.g. \"prod\""
}

variable "instance_type" {
  description = "Elastic Search instance type, e.g. \"t3.medium.elasticsearch\""
}

