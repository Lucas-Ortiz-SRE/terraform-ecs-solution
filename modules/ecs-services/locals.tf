locals {
  secret_keys = var.secrets_arn != "" ? keys(jsondecode(data.aws_secretsmanager_secret_version.this[0].secret_string)) : []
  secrets = [
    for key in local.secret_keys : {
      name      = key
      valueFrom = "${var.secrets_arn}:${key}::"
    }
  ]
}