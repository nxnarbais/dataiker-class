# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret
resource "aws_secretsmanager_secret" "datadog_api_key_secret" {
  name = "${var.service}-secrets-${var.team}"
  tags = {
    env = var.env
    service = var.service
    team = var.team
  }
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "secret_version" {
  secret_id     = aws_secretsmanager_secret.datadog_api_key_secret.id
  secret_string = var.datadog_api_key
}