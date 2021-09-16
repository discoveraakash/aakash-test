terraform {
  required_version = "~>1.0.4"
}

provider "aws" {
  version = ">= 3.50"
  region  = var.region
}

module "vpc" {
  source             = "./vpc"
  name               = var.name
  environment        = var.environment
  cidr               = var.cidr
  private_subnets    = var.private_subnets
  public_subnets     = var.public_subnets
  availability_zones = var.availability_zones
}

module "eks" {
  source          = "./eks"
  name            = var.name
  environment     = var.environment
  region          = var.region
  project         = "aakas-lcms"
  k8s_version     = var.k8s_version
  vpc_id          = module.vpc.id
  private_subnets = module.vpc.private_subnets
  public_subnets  = module.vpc.public_subnets
  kubeconfig_path = var.kubeconfig_path
}

module "rds" {
  source                = "./rds"
  name                  = var.name
  environment           = var.environment
  instance_class        = var.rds_instance_class
  vpc_id                = module.vpc.id
  private_subnets       = module.vpc.private_subnets
  public_subnets        = module.vpc.public_subnets
  cidr_block            = var.cidr
  db_subnet_group_id    = module.vpc.db_subnet_group
  rds_user_name         = var.rds_username
  rds_user_password     = var.rds_userpassword 
}

#module "documentdb" {
#  source               = "./documentdb"
#  name                 = var.name
#  environment          = var.environment
#  db_subnet_group_id   = module.vpc.db_subnet_group
#  master_user_name     = var.docdb_user_name
#  master_user_password = var.docdb_user_password
#  db_instance_class    = var.docdb_instance_class
#}

#module "dynamo" {
#  source          = "./dynamo"
#  name            = var.name
#  environment     = var.environment
#}

#module "radis" {
#  source                = "./radis"
#  name                  = var.name
#  environment           = var.environment
#  node_type             = var.radis_node_type
#  cache_subnet_group_id = module.vpc.cache_subnet_group
#}

#module "elk" {
#  source = "./elk"
#  name                  = var.name
#  environment           = var.environment
#  domain                = var.domain
#  vpc_id                = module.vpc.id
#  private_subnets       = module.vpc.private_subnets
#  public_subnets        = module.vpc.public_subnets
#  master_user_name      = var.master_user_name
#  master_user_password  = var.master_user_password
#  vpc_cidr_blocks       = var.cidr
#  instance_type         = var.elk_instance_type
#}

module "albc" {
  source                    = "./albc"
  name                      = var.name
  environment               = var.environment
  aws_vpc_id                = module.vpc.id
  aws_region_name           = var.region
  alb_controller_depends_on = module.eks 
}

#module "sqs" {
#  source          = "./sqs"
#  name            = var.name
#  environment     = var.environment
#}

module "api_gateway" {
  source              = "./api_gateway"
  name                = var.name
  environment         = var.environment
  api_domain          = var.api_gateway_subdomain
  main_domain         = var.main_domain
  api_certificate_arn = var.api_gateway_certificate_arn
  zone_id             = var.hosted_zone_id
}

module "waf2" {
  source            = "./waf2"
  name              = var.name
  environment       = var.environment
  api_arn           = module.api_gateway.api_gateway_arn
  #allow_default_action = true # set to allow if not specified
  visibility_config = {
    metric_name = "test-waf-setup-waf-main-metrics"
  }

  rules = [
    {
      name     = "AWSManagedRulesCommonRuleSet-rule-1"
      priority = "1"
      override_action = "none"
      visibility_config = {
        metric_name                = "AWSManagedRulesCommonRuleSet-metric"
      }

      managed_rule_group_statement = {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
        excluded_rule = [
          "SizeRestrictions_QUERYSTRING",
          "SizeRestrictions_BODY",
          "GenericRFI_QUERYARGUMENTS"
        ]
      }
    },
    {
      name     = "AWSManagedRulesKnownBadInputsRuleSet-rule-2"
      priority = "2"
      override_action = "count"
      visibility_config = {
        metric_name = "AWSManagedRulesKnownBadInputsRuleSet-metric"
      }
      managed_rule_group_statement = {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    },
    {
      name     = "AWSManagedRulesPHPRuleSet-rule-3"
      priority = "3"
      override_action = "none"
      visibility_config = {
        cloudwatch_metrics_enabled = false
        metric_name                = "AWSManagedRulesPHPRuleSet-metric"
        sampled_requests_enabled   = false
      }
      managed_rule_group_statement = {
        name        = "AWSManagedRulesPHPRuleSet"
        vendor_name = "AWS"
      }
    },
    ### Byte Match Rule
    {
      name     = "ByteMatchRule-4"
      priority = "4"
      action = "count"
      visibility_config = {
        cloudwatch_metrics_enabled = false
        metric_name                = "ByteMatchRule-metric"
        sampled_requests_enabled   = false
      }

      byte_match_statement = {
        field_to_match = {
          uri_path = "{}"
        }
        positional_constraint = "STARTS_WITH"
        search_string         = "/path/to/match"
        priority              = 0
        type                  = "NONE"
      }
    },
    ### Geo Match Rule
    {
      name     = "GeoMatchRule-5"
      priority = "5"
      action = "allow"
      visibility_config = {
        cloudwatch_metrics_enabled = false
        metric_name                = "GeoMatchRule-metric"
        sampled_requests_enabled   = false
      }
      geo_match_statement = {
        country_codes = ["NL", "GB", "US"]
      }
    },
    ### IP Set Rule example
   /* {
      name     = "IpSetRule-6"
      priority = "6"
      action = "allow"
      visibility_config = {
        cloudwatch_metrics_enabled = false
        metric_name                = "IpSetRule-metric"
        sampled_requests_enabled   = false
      }
      ip_set_reference_statement = {
        arn = "arn:aws:wafv2:eu-west-1:111122223333:regional/ipset/ip-set-test/a1bcdef2-1234-123a-abc0-1234a5bc67d8"
      }
    },*/
    ### IP Rate Based Rule example
    {
      name     = "IpRateBasedRule-7"
      priority = "6"
      action = "block"
      visibility_config = {
        cloudwatch_metrics_enabled = false
        metric_name                = "IpRateBasedRule-metric"
        sampled_requests_enabled   = false
      }

      rate_based_statement = {
        limit              = 100
        aggregate_key_type = "IP"
        # Optional scope_down_statement to refine what gets rate limited
        scope_down_statement = {
          not_statement = {
            byte_match_statement = {
              field_to_match = {
                uri_path = "{}"
              }
              positional_constraint = "STARTS_WITH"
              search_string         = "/path/to/match"
              priority              = 0
              type                  = "NONE"
            }
          }
        }
      }
    },
    ### NOT rule (can be applied to byte_match, geo_match, and ip_set rules)
    {
      name     = "NotByteMatchRule-8"
      priority = "7"
      action = "count"
      visibility_config = {
        cloudwatch_metrics_enabled = false
        metric_name                = "NotByteMatchRule-metric"
        sampled_requests_enabled   = false
      }

      not_statement = {
        byte_match_statement = {
          field_to_match = {
            uri_path = "{}"
          }
          positional_constraint = "STARTS_WITH"
          search_string         = "/path/to/match"
          priority              = 0
          type                  = "NONE"
        }
      }
    }
  ]
}

#module "cloudfront" {
#  source              = "./cdn"
#  name                = var.name
#  environment         = var.environment
#  cdn_domain          = var.cdn_subdomain
#  api_domain          = var.api_gateway_subdomain
#  api_certificate_arn = var.api_gateway_certificate_arn
#  zone_id             = var.hosted_zone_id
#  main_domain         = var.main_domain
#}

#module "lambda_function" {
#  source          = "./lambda"
#  name            = var.name
#  environment     = var.environment
#  vpc_id          = module.vpc.id
#  private_subnets = module.vpc.private_subnets
#  public_subnets  = module.vpc.public_subnets
#  apigateway_arn = module.api_gateway.api_gateway_arn
#}

module "hpa" {
  source          = "./hpa"
}
