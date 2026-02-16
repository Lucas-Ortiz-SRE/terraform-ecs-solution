#=============================================================================================
# IAM ROLES MODULE
#=============================================================================================
module "iam_roles" {
  source   = "./modules/iam-roles"
  for_each = var.ecs_services

  project_name = var.project_name
  environment  = var.environment
  service_name = each.key
}

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
# ALB MODULE (Condicional - só cria se não existir)
#=============================================================================================
module "alb" {
  source = "./modules/alb"
  count  = var.alb_listener_arn == "" ? 1 : 0

  project_name    = var.project_name
  environment     = var.environment
  vpc_id          = var.vpc_id
  subnets         = var.alb_subnets
  security_groups = var.alb_security_groups
  certificate_arn = var.certificate_arn
  alb_internal    = var.alb_internal
}

locals {
  alb_listener_arn = var.alb_listener_arn != "" ? var.alb_listener_arn : try(module.alb[0].listener_arn, "")
}

#=============================================================================================
# ECS SERVICES MODULE
#=============================================================================================
module "ecs_services" {
  source   = "./modules/ecs-services"
  for_each = var.ecs_services

  # Informações Básicas
  project_name = var.project_name
  environment  = var.environment
  service_name = "${var.project_name}-${var.environment}-${each.key}"
  cluster_id   = module.ecs_cluster.cluster_id
  cluster_name = module.ecs_cluster.cluster_name

  # Definições do Contentor e da Task
  container_image = each.value.container_image
  container_port  = each.value.container_port
  task_cpu        = each.value.task_cpu
  task_memory     = each.value.task_memory
  secrets_arn     = each.value.secrets_arn

  # Observabilidade
  log_retention_in_days = each.value.log_retention_in_days

  # Roles de IAM
  execution_role_arn = module.iam_roles[each.key].ecs_execution_role_arn
  task_role_arn      = module.iam_roles[each.key].ecs_task_role_arn

  # Rede e Escalonamento
  desired_count   = each.value.desired_count
  subnets         = each.value.subnets
  security_groups = each.value.security_groups

  # Load Balancer
  create_target_group = each.value.create_target_group
  health_check_path   = each.value.health_check_path
  vpc_id              = var.vpc_id
  alb_listener_arn    = local.alb_listener_arn
  alb_priority        = each.value.alb_priority
  host_header         = each.value.host_header

  # Tags
  application_tag = each.value.application_tag
  cost_center     = each.value.cost_center
}