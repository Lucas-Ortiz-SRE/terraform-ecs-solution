output "alb_security_group_id" {
  value = var.create_alb && var.create_alb_security_group ? aws_security_group.alb[0].id : null
}

output "ecs_service_security_group_ids" {
  value = { for k, v in aws_security_group.ecs_service : k => v.id }
}

output "alb_security_groups" {
  value = var.create_alb_security_group ? [aws_security_group.alb[0].id] : var.alb_security_groups
}
