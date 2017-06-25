resource "aws_iam_role" "urlinfo_cloudwatch_events_role" {
  name = "${var.project_name}-cloudwatch-events-role"

  assume_role_policy = "${data.aws_iam_policy_document.urlinfo_cloudwatch_events_role_assume_policy.json}"
}

resource "aws_iam_role_policy" "urlinfo_cloudwatch_events_role_policy" {
  name = "${var.project_name}-cloudwatch-events-policy"
  role = "${aws_iam_role.urlinfo_cloudwatch_events_role.id}"
  policy = "${data.aws_iam_policy_document.urlinfo_cloudwatch_events_role_policy.json}"
}

####
# 
####

data "aws_iam_policy_document" "urlinfo_cloudwatch_events_role_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "urlinfo_cloudwatch_events_role_policy" {
  statement {
    sid = "AllowCloudWatchEventsInvokeLambda"

    actions = ["lambda:InvokeFunction"]
    resources = ["${aws_lambda_function.urlinfo_lambda.arn}"]
  }
}
