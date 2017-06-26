# Lambda requires internet access to download the demo URL Blacklist, but also
# requires to be in the same VPC as ElastiCache.
#
# To achieve this without making potentially dangerous changes to the default VPC's
# existing configuration or subnets, we will create another subnet, routing table
# and NAT Gateway instance in the higher range of 172.31.0.0/16 (default VPC CIDR block).

resource "aws_subnet" "urlinfo_subnet" {
  vpc_id = "${data.aws_vpc.default.id}"
  cidr_block = "172.31.240.0/24"

  tags {
    Name = "${var.project_name}-subnet"
  }
}

resource "aws_eip" "urlinfo_nat_gateway" {
  vpc = true
}

resource "aws_nat_gateway" "urlinfo_nat_gateway" {
  allocation_id = "${aws_eip.urlinfo_nat_gateway.id}"
  subnet_id     = "${data.aws_subnet.default.id}"
}

resource "aws_route_table" "urlinfo_route_table" {
  vpc_id = "${data.aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.urlinfo_nat_gateway.id}"
  }
}

resource "aws_route_table_association" "urlinfo_subnet_rta" {
  subnet_id = "${aws_subnet.urlinfo_subnet.id}"
  route_table_id = "${aws_route_table.urlinfo_route_table.id}"
}

