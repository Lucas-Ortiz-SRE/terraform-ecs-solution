output "target_group_arn" {
  description = "ARN do Target Group criado (nulo se create_target_group for false)"
  # Se foi criado, exporta o ARN. Se não, exporta null.
  value = var.create_target_group ? aws_lb_target_group.this[0].arn : null
}