resource "aws_api_gateway_rest_api" "api_gateway" {
  name        = "${var.service}-api-gtw-${var.team}"
  description = "demo lambda for Dataiker"
  tags = {
    env = var.env
    service = var.service
    team = var.team
  }
}

#########################################################
# MAIN ENDPOINT
# GET /
#########################################################

resource "aws_api_gateway_method" "main_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "main_get_method_response" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_rest_api.api_gateway.root_resource_id
  http_method = aws_api_gateway_method.main_get.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = false
  }
}

resource "aws_api_gateway_integration" "main_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_rest_api.api_gateway.root_resource_id
  http_method             = aws_api_gateway_method.main_get.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.example_lambda.invoke_arn
}

#########################################################
# WITH DATADOG ENDPOINT
# GET /with-datadog
#########################################################


resource "aws_api_gateway_resource" "with_datadog" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "with-datadog"
}

resource "aws_api_gateway_method" "with_datadog_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.with_datadog.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "with_datadog_get_method_response" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.with_datadog.id
  http_method = aws_api_gateway_method.with_datadog_get.http_method
  status_code = "200"

  # response_parameters = {
  #   "method.response.header.Access-Control-Allow-Headers" = true,
  #   "method.response.header.Access-Control-Allow-Methods" = true,
  #   "method.response.header.Access-Control-Allow-Origin"  = false
  # }
}

resource "aws_api_gateway_integration" "with_datadog_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.with_datadog.id
  http_method             = aws_api_gateway_method.with_datadog_get.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = module.lambda-datadog.invoke_arn
}

#########################################################
# GLOBAL PERMISSIONS
#########################################################

resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.example_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/*"
}

resource "aws_lambda_permission" "api_gateway_permission_with_datadog" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda-datadog.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/*"
}

#########################################################
# SELECT WHICH ENDPOINTS TO DEPLOY
#########################################################

resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [
    aws_api_gateway_method.main_get,
    aws_api_gateway_method.with_datadog_get,
  ]

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
}

resource "aws_api_gateway_stage" "api_stage_beta" {
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  stage_name    = "beta"
}