provider "aws" {
  region = var.aws_region
}

terraform {
  required_version = ">= 1.6.6"
  # This avoids AWS 5.86.0 which introduced an S3 bug:
  # https://github.com/hashicorp/terraform-provider-aws/issues/41278
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.85.0"
    }
  }
}
