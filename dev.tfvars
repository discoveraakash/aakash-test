variable "name" {
  description = "the name of your stack, e.g. \"demo\""
  default     = "aakash-test-player"
}

variable "environment" {
  description = "the name of your environment, e.g. \"prod\""
  default     = "dev"
}

variable "region" {
  description = "the AWS region in which resources are created, you must set the availability_zones variable as well if you define this value to something other than the default"
  default     = "us-east-1"
}

variable "availability_zones" {
  description = "a comma-separated list of availability zones, defaults to all AZ of the region, if set to something other than the defaults, both private_subnets and public_subnets have to be defined as well"
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "cidr" {
  description = "The CIDR block for the VPC."
  default     = "10.0.0.0/16"
}

variable "private_subnets" {
  description = "a list of CIDRs for private subnets in your VPC, must be set if the cidr variable is defined, needs to have as many elements as there are availability zones"
  default     = ["10.0.0.0/20", "10.0.32.0/20", "10.0.64.0/20"]
}

variable "public_subnets" {
  description = "a list of CIDRs for public subnets in your VPC, must be set if the cidr variable is defined, needs to have as many elements as there are availability zones"
  default     = ["10.0.16.0/20", "10.0.48.0/20", "10.0.80.0/20"]
}

variable "kubeconfig_path" {
  description = "Path where the config file for kubectl should be written to"
  default     = "~/.kube"
}

variable "k8s_version" {
  description = "kubernetes version"
  default = ""
}

# Variables for RDS
######################################
variable "rds_username" {
  type = string
  default = "aakash"
}
variable "rds_userpassword" {
  type = string
  default = "aakashTestPlayer"
}

# Variables for ELK
######################################
variable "domain" {
  type = string
  default = "aakash-test-player"
}
variable "master_user_name" {
  type = string
  default = "admin"
}
variable "master_user_password" {
  type = string
  default = "Password@123"
}


# Variables for DocumentDB
######################################
variable "docdb_user_name" {
  type = string
  default = "aakash"
}
variable "docdb_user_password" {
  type = string
  default = "Password123"
}

# Variables for API_Gateway
######################################
variable "api_gateway_certificate_arn" {
  type = string
#########Aakash aakash.ac.in#############
  #default =  "arn:aws:acm:us-east-1:910393620193:certificate/ed44a905-ac64-46eb-85e5-d9377b1556e9"
#########Mohit mohit-garg.com#############
  default = "arn:aws:acm:us-east-1:779284741636:certificate/d784c37f-260e-449a-9e1d-b0c724fa5fa7"
}

variable "main_domain" {
  description = "Enter Main Domain, e.g. \"example.com\""
  type = string
  default = "mohit-garg.com"
}

variable "api_gateway_subdomain" {
  description = "Enter subdomain for API-Gateway mapping, e.g. \"prodapi\""
  type = string
  default = "api"
}

variable "hosted_zone_id" {
  description = "Enter Zone Id of Main Domain, e.g. \"ZXNFJSOWXXX\""
  type = string
  default = "Z01628049MEBOP5SPXFE"
}

# Variables for Cloud Front
######################################
variable "cdn_subdomain" {
  description = "Enter subdomain for cloudfront, e.g. \"prodcdn\""
  type = string
  default = "cdn"
}

variable "alb_controller_depends_on" {
  description = "Resources that the module should wait for before starting the controller. For example if there is no node_group, 'aws_eks_fargate_profile.default'"
}