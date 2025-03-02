module "lambda-datadog" {
  source  = "DataDog/lambda-datadog/aws"
  version = "2.0.0"

  environment_variables = {
    "DD_API_KEY_SECRET_ARN" : aws_secretsmanager_secret.datadog_api_key_secret.arn
    "DD_ENV" : var.env
    "DD_SERVICE" : var.service
    "DD_SITE": var.datadog_site
    "DD_VERSION" : var.lambda_version
		"ENV_VAR": var.env_var
    "DD_TRACE_OTEL_ENABLED": "false"
    "DD_PROFILING_ENABLED": "false"
    "DD_SERVERLESS_APPSEC_ENABLED": "false"
  }

  datadog_extension_layer_version = 67
  datadog_node_layer_version = 117

  # aws_lambda_function arguments

	function_name = "${var.service}-${var.team}-with-datadog"
  runtime       = "nodejs18.x"  # Adjust according to your Node.js version
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"

  # filename = var.lambda_zip_filepath
	# source_code_hash = filebase64sha256(var.lambda_zip_filepath)
  filename      = "lambda_function_payload.zip"
  source_code_hash = data.archive_file.lambda.output_base64sha256

  timeout       = 30
	memory_size   = 128
  # reserved_concurrent_executions = 3  # Limit to X concurrent executions

  tags = {
    env = var.env
    service = var.service
    team = var.team
    version = var.lambda_version
    datadog_monitored = "true"
  }
}

# Create CloudWatch Log Group (optional)
resource "aws_cloudwatch_log_group" "lambda_log_group_with_datadog" {
  name              = "/aws/lambda/${module.lambda-datadog.function_name}"
  retention_in_days = 3  # Optional: Log retention period
}
