resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${var.name}-${var.environment}-redis"
  engine               = "redis"
  node_type            = var.node_type
  num_cache_nodes      = 1
  parameter_group_name = "default.redis5.0"
  engine_version       = "5.0.6"
  port                 = 6379
  subnet_group_name    = "${var.cache_subnet_group_id}"

  tags = {
    Product     = var.name
    Environment = var.environment
  }
}