resource "aws_docdb_cluster" "docdb" {
  cluster_identifier      = "${var.name}-${var.environment}-docdb"
  engine                  = "docdb"
  master_username         = var.master_user_name
  master_password         = var.master_user_password
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  skip_final_snapshot     = true
  db_subnet_group_name    = "${var.db_subnet_group_id}"
}

resource "aws_docdb_cluster_instance" "docdb_instances" {
  count                   = 1
  identifier              = "${var.name}-${var.environment}-docdb-${count.index}"
  cluster_identifier      = aws_docdb_cluster.docdb.id
  instance_class          = var.db_instance_class
}
