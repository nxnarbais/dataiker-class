data "archive_file" "lambda" {
  type        = "zip"
  source_file = "../function/index.mjs"
  output_path = "lambda_function_payload.zip"
}

resource "aws_lambda_function" "example_lambda" {
  function_name = "${var.service}-${var.team}"
  runtime       = "nodejs18.x"  # Adjust according to your Node.js version
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"

  # filename = var.lambda_zip_filepath
	# source_code_hash = filebase64sha256(var.lambda_zip_filepath)
  filename      = "lambda_function_payload.zip"
  source_code_hash = data.archive_file.lambda.output_base64sha256

  timeout       = 30
	memory_size   = 128
  reserved_concurrent_executions = 3  # Limit to X concurrent executions

  environment {
    variables = {
      ENV_VAR=var.env_var
    }
  }

  tags = {
    env = var.env
    service = var.service
    team = var.team
    version = var.lambda_version
    datadog_monitored = "true"
  }
}

# Create CloudWatch Log Group (optional)
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.example_lambda.function_name}"
  retention_in_days = 3  # Optional: Log retention period
}
