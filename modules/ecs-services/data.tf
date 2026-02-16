data "aws_region" "current" {}

data "aws_secretsmanager_secret_version" "this" {
  count     = var.secrets_arn != "" ? 1 : 0
  secret_id = var.secrets_arn
}

