variable "name" {
  description = "the name of your stack, e.g. \"demo\""
}

variable "environment" {
  description = "the name of your environment, e.g. \"prod\""
}

variable "db_subnet_group_id" {
  description = "Subnet Group ID"
}

variable "master_user_name" {
  description = "Document db master username, e.g. \"prod\""
}

variable "master_user_password" {
  description = "Document db master password, e.g. \"prod\""
}

variable "db_instance_class" {
  description = "Document db instance class, e.g. \"db.r5.large\""
}