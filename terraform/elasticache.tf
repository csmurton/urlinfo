resource "aws_elasticache_subnet_group" "urlinfo_subnet_group" {
  name            = "${var.project_name}-subnet-group"
  description     = "ElastiCache subnet group for use with urlinfo"
  subnet_ids      = ["${aws_subnet.urlinfo_subnet.id}"]
}

resource "aws_elasticache_cluster" "urlinfo_cluster" {
  cluster_id           = "${var.project_name}"
  engine               = "redis"
  engine_version       = "${var.elasticache_engine_version}"
  node_type            = "${var.elasticache_node_type}"
  num_cache_nodes      = "${var.elasticache_num_cache_nodes}"
  parameter_group_name = "${var.elasticache_parameter_group_name}"
  port                 = "${var.elasticache_port}"
  security_group_ids   = ["${aws_security_group.urlinfo_sg.id}"]
  subnet_group_name    = "${aws_elasticache_subnet_group.urlinfo_subnet_group.name}"
}

