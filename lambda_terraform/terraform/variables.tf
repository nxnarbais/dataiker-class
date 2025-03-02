variable "aws_region" {
  description = "AWS Region"
  default     = "eu-west-3"
}

variable "env" {
  description = "Environment variable"
  default = "staging"
  type = string
}

variable "service" {
  description = "Service name"
  default = "lambda-demo"
  type = string
}

variable "team" {
  description = "Team name (no space)"
  default = "dataiker"
  type = string
}

variable "env_var" {
  description = "value of environment variable"
  default = "nothing"
}

variable lambda_version {
  description = "Lambda version"
  default = "0.3.1"
}

variable datadog_site {
  description = "Datadog site"
  default = "datadoghq.eu"
}

variable "datadog_api_key" {
  description = "Datadog API key"
  default = "somekey"
}
