output "cluster_id" {
  description = "O ID do cluster ECS criado"
  value       = aws_ecs_cluster.this.id
}

output "cluster_name" {
  description = "O nome do cluster ECS criado"
  value       = aws_ecs_cluster.this.name
}