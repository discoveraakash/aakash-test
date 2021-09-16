data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

resource "aws_security_group" "es" {
  name        = "elasticsearch-${var.domain}"
  description = "Managed by Aakash"
  vpc_id      =  var.vpc_id

ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = [
     var.vpc_cidr_blocks
    ]
  }
tags = {
    Product = var.name
    Environment = var.environment
  }
}


resource "aws_elasticsearch_domain" "es" {
  domain_name           = var.domain
  elasticsearch_version = "7.10"

cluster_config {
      instance_type = var.instance_type
      instance_count = 3
      zone_awareness_config {
      availability_zone_count = 3
      }
      zone_awareness_enabled = true
  }

ebs_options {
    ebs_enabled = true
    volume_size = "20"
  }
node_to_node_encryption {
    enabled = true
  }
encrypt_at_rest {
    enabled = true
  }
domain_endpoint_options {
    enforce_https = true
    tls_security_policy = "Policy-Min-TLS-1-0-2019-07"
  }
vpc_options {
    subnet_ids = ["${element(var.public_subnets.*.id,0)}", "${element(var.public_subnets.*.id,1)}" ,"${element(var.public_subnets.*.id,2)}"]
    security_group_ids = [aws_security_group.es.id]
  }

advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }
advanced_security_options {
    enabled = true
    internal_user_database_enabled = true
    master_user_options {
      master_user_name = var.master_user_name
      master_user_password = var.master_user_password
    }
  }

access_policies = <<CONFIG
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:*",
            "Principal": "*",
            "Effect": "Allow",
            "Resource": "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${var.domain}/*"
        }
    ]
}
CONFIG

  snapshot_options {
    automated_snapshot_start_hour = 23
  }

tags = {
    Domain = "Aakash-test-player"
    Product = var.name
    Environment = var.environment
  }

}
