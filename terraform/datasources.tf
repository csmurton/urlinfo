data "aws_caller_identity" "current" {}

data "aws_vpc" "default" {
  default = true
}

# Pick the pre-existing default subnet in the same AZ as our custom subnet in the default VPC
data "aws_subnet" "default" {
  vpc_id = "${data.aws_vpc.default.id}"
  default_for_az = true
  availability_zone = "${aws_subnet.urlinfo_subnet.availability_zone}"
}
