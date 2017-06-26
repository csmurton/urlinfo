resource "aws_security_group" "urlinfo_sg" {
  name_prefix     = "${var.project_name}-sg-"
  description     = "Security group allowing urlinfo resources to communicate together"
  vpc_id          = "${data.aws_vpc.default.id}"

  ingress {
    from_port = "${var.elasticache_port}"
    to_port = "${var.elasticache_port}"
    protocol = "tcp"
    self = true
  }

  egress {
    from_port = "${var.elasticache_port}"
    to_port = "${var.elasticache_port}"
    protocol = "tcp"
    self = true
  }

  # Require outbound access to retrieve demo URL blacklist
  egress {
    from_port = "80"
    to_port = "80"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
