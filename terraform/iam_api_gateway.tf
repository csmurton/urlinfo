resource "aws_iam_role" "urlinfo_apigateway_role" {
  name = "${var.project_name}-apigateway-role"

  assume_role_policy = "${data.aws_iam_policy_document.urlinfo_apigateway_role_assume_policy.json}"
}

resource "aws_iam_role_policy" "urlinfo_apigateway_role_policy" {
  name = "${var.project_name}-apigateway-policy"
  role = "${aws_iam_role.urlinfo_apigateway_role.id}"
  policy = "${data.aws_iam_policy_document.urlinfo_apigateway_role_policy.json}"
}

####
# 
####

data "aws_iam_policy_document" "urlinfo_apigateway_role_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "urlinfo_apigateway_role_policy" {
  statement {
    sid = "AllowAPIGatewayInvokeLambda"

    actions = ["lambda:InvokeFunction"]
    resources = ["${aws_lambda_function.urlinfo_lambda.arn}"]
  }
}
