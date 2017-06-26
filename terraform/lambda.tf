data "archive_file" "urlinfo_lambda" {
  type        = "zip"
  source_dir  = "../node"
  output_path = "${path.module}/files/urlinfo.zip"
}

resource "aws_lambda_function" "urlinfo_lambda" {
  description = "Handles requests to determine whether a URL is malicious or not"
  environment {
    variables {
      DATABASE_PROVIDER = "redis"
      DATABASE_HOST     = "${aws_elasticache_cluster.urlinfo_cluster.cache_nodes.0.address}"
      DATABASE_PORT     = "${var.elasticache_port}"
    }
  }
  filename         = "${data.archive_file.urlinfo_lambda.output_path}"
  function_name    = "${var.project_name}"
  handler          = "url-info.handler"
  role             = "${aws_iam_role.urlinfo_lambda_role.arn}"
  timeout          = "60"
  source_code_hash = "${data.archive_file.urlinfo_lambda.output_base64sha256}"
  runtime          = "nodejs6.10"
  vpc_config {
    security_group_ids = ["${aws_security_group.urlinfo_sg.id}"]
    subnet_ids         = ["${aws_subnet.urlinfo_subnet.id}"]
  }
}

resource "aws_lambda_permission" "urlinfo_lambda_allow_cloudwatch_events" {
  statement_id  = "AllowInvocationFromCloudWatchEvents"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.urlinfo_lambda.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.urlinfo_lambda_event_rule_ping.arn}"
}

resource "aws_lambda_permission" "urlinfo_lambda_allow_api_gateway" {
  statement_id  = "AllowInvocationFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.urlinfo_lambda.function_name}"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.urlinfo.id}/*/*/*"
}
