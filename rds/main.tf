resource "aws_security_group" "sg" {
  name        = "${var.name}-${var.environment}-db-sg"
  description = "Allow kubernetes custer traffic only"
  vpc_id      = var.vpc_id
}
resource "aws_rds_cluster_instance" "cluster_instances" {
  count                       = 2
  identifier                  = "${var.name}-${var.environment}-rds-${count.index}"
  cluster_identifier          = aws_rds_cluster.aakash_rds.id
  instance_class              = var.instance_class
  engine                      = "aurora-mysql"
  engine_version              = "5.7.mysql_aurora.2.07.2"
  apply_immediately           = false
  auto_minor_version_upgrade  = false

  tags = {
    Product = var.name
    Environment = var.environment
  }
}
resource "aws_rds_cluster" "aakash_rds" {
  cluster_identifier          = "${var.name}-${var.environment}-rds"
  engine                      = "aurora-mysql"
  engine_version              = "5.7.mysql_aurora.2.07.2"
  database_name               = "aakashTestPlayerRDS"
  master_username             = var.rds_user_name
  master_password             = var.rds_user_password
  storage_encrypted           = true
  apply_immediately           = true
  skip_final_snapshot         = true
  deletion_protection         = true
  vpc_security_group_ids      = [aws_security_group.sg.id]
  db_subnet_group_name        = "${var.db_subnet_group_id}"

  tags = {
    Product = var.name
    Environment = var.environment
  }
}