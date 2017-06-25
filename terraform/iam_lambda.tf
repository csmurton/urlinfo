resource "aws_iam_role" "urlinfo_lambda_role" {
  name = "${var.project_name}-lambda-role"
#  description = "IAM role for use by the Lambda function ${var.project_name}."

  assume_role_policy = "${data.aws_iam_policy_document.urlinfo_lambda_role_assume_policy.json}"
}

resource "aws_iam_role_policy" "urlinfo_lambda_role_policy" {
  name = "${var.project_name}-lambda-policy"
  role = "${aws_iam_role.urlinfo_lambda_role.id}"
  policy = "${data.aws_iam_policy_document.urlinfo_lambda_role_policy.json}"
}

####
# Trust Relationship/Assume Role policy and IAM policy for Lambda function's IAM role
####

data "aws_iam_policy_document" "urlinfo_lambda_role_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}
 
data "aws_iam_policy_document" "urlinfo_lambda_role_policy" {
  statement {
    actions = [
      "lambda:InvokeFunction"
    ]

    resources = [ "*" ]
  }

  statement {
    sid = "AllowPutCloudWatchLogGroup"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ]

    resources = [
      "${aws_cloudwatch_log_group.urlinfo_lambda_log_group.arn}"
    ]
  }

  statement {
    sid = "AllowENIActionsForVPCAccess"

    actions = [
      "ec2:AttachNetworkInterface",
      "ec2:CreateNetworkInterface",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeInstances",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DetachNetworkInterface",
      "ec2:ModifyNetworkInterfaceAttribute",
      "ec2:ResetNetworkInterfaceAttribute"
    ]

    resources = [ "*" ]
  }
}
