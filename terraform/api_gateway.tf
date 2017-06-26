resource "aws_api_gateway_rest_api" "urlinfo" {
  name        = "URLInfo"
  description = "API to provide information on malicious URLs"
}

resource "aws_api_gateway_deployment" "urlinfo" {
  depends_on = ["aws_api_gateway_integration.urlinfo_root_integration"]
  rest_api_id = "${aws_api_gateway_rest_api.urlinfo.id}"
  stage_name = "${var.api_gateway_deployment_stage}"

  provisioner "local-exec" {
    command = "/usr/bin/curl -q ${aws_api_gateway_deployment.urlinfo.invoke_url}/urlloader"
  }
}

# API Gateway resources

resource "aws_api_gateway_resource" "urlinfo_proxy_resource" {
  rest_api_id  = "${aws_api_gateway_rest_api.urlinfo.id}"
  parent_id    = "${aws_api_gateway_rest_api.urlinfo.root_resource_id}"
  path_part    = "{proxy+}"
}

# API Gateway methods

resource "aws_api_gateway_method" "urlinfo_root_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.urlinfo.id}"
  resource_id   = "${aws_api_gateway_rest_api.urlinfo.root_resource_id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "urlinfo_proxy_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.urlinfo.id}"
  resource_id   = "${aws_api_gateway_resource.urlinfo_proxy_resource.id}"
  http_method   = "ANY"
  authorization = "NONE"
}

# API Gateway integrations

resource "aws_api_gateway_integration" "urlinfo_root_integration" {
  credentials             = "${aws_iam_role.urlinfo_apigateway_role.arn}"
  http_method             = "${aws_api_gateway_method.urlinfo_root_method.http_method}"
  integration_http_method = "POST"
  resource_id             = "${aws_api_gateway_rest_api.urlinfo.root_resource_id}"
  rest_api_id             = "${aws_api_gateway_rest_api.urlinfo.id}"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${aws_lambda_function.urlinfo_lambda.arn}/invocations"
}

resource "aws_api_gateway_integration" "urlinfo_proxy_integration" {
  credentials             = "${aws_iam_role.urlinfo_apigateway_role.arn}"
  http_method             = "${aws_api_gateway_method.urlinfo_proxy_method.http_method}"
  integration_http_method = "POST"
  rest_api_id             = "${aws_api_gateway_rest_api.urlinfo.id}"
  resource_id             = "${aws_api_gateway_resource.urlinfo_proxy_resource.id}"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${aws_lambda_function.urlinfo_lambda.arn}/invocations"
}
