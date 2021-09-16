variable "name" {
  description = "the name of your stack, e.g. \"demo\""
}

variable "environment" {
  description = "the name of your environment, e.g. \"prod\""
}

variable "main_domain" {
  description = "the name of your domain, e.g. \"prod\""
}

variable "api_domain" {
  description = "the name of your domain, e.g. \"prod\""
}

variable "cdn_domain" {
  description = "the name of your domain, e.g. \"prod\""
}

variable "api_certificate_arn" {
  description = "the arn of your certificate, e.g. \"prod\""
}

variable "zone_id" {
  description = "Zone id of domain"
}