#=============================================================================================
# ECS CLUSTER MODULE
#=============================================================================================
module "ecs_cluster" {
  source = "./modules/ecs-cluster"

  cluster_name = "${var.environment}-${var.project_name}-cluster"

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

#=============================================================================================
# ECS SERVICES MODULE
#=============================================================================================
module "ecs_services" {
  source   = "./modules/ecs-service"
  for_each = var.ecs_services

  # Informações Básicas
  service_name = each.key
  cluster_id   = module.ecs_cluster.cluster_id
  cluster_name = module.ecs_cluster.cluster_name

  # Definições do Contentor e da Task
  container_name  = each.value.container_name
  container_image = each.value.container_image
  container_port  = try(each.value.container_port, 8080)
  task_cpu        = try(each.value.task_cpu, "256")
  task_memory     = try(each.value.task_memory, "512")
  
  environment_variables = try(each.value.environment_variables, [])

  # Roles de IAM (Que virão futuramente do seu módulo modules/iam-roles)
  execution_role_arn = var.ecs_execution_role_arn
  task_role_arn      = var.ecs_task_role_arn

  # Rede e Escalonamento
  desired_count   = try(each.value.desired_count, 1)
  subnets         = each.value.subnets
  security_groups = each.value.security_groups

  # Load Balancer (Tratado de forma segura com o try)
  target_group_arn = try(each.value.load_balancer.target_group_arn, null)
}