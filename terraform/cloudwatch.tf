resource "aws_cloudwatch_log_group" "urlinfo_lambda_log_group" {
  name = "/aws/lambda/${var.project_name}"
  retention_in_days = "${var.cloudwatch_log_retention_in_days}"
}

resource "aws_cloudwatch_event_rule" "urlinfo_lambda_event_rule_ping" {
  name = "${var.project_name}-lambda-ping"
  description = "Event to ping the Lambda function at regular intervals to keep an underlying container 'warm' (faster response)."
  schedule_expression = "rate(5 minutes)"
  role_arn = "${aws_iam_role.urlinfo_cloudwatch_events_role.arn}"
}

resource "aws_cloudwatch_event_target" "urlinfo_lambda_event_target" {
  arn       = "${aws_lambda_function.urlinfo_lambda.arn}"
  rule      = "${aws_cloudwatch_event_rule.urlinfo_lambda_event_rule_ping.name}"
  target_id = "urlinfo_lambda"
}
