variable "name" {
  description = "the name of your stack, e.g. \"demo\""
}

variable "environment" {
  description = "the name of your environment, e.g. \"prod\""
}

variable "cache_subnet_group_id" {
  description = "Cache Subnet Group ID"
}

variable "node_type" {
  description = "Cache Node type"
}