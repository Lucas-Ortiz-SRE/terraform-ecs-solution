#=============================================================================================
# VPC MODULE (Condicional - só cria se não existir)
#=============================================================================================
module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
  environment  = var.environment

  create_vpc               = var.create_vpc
  vpc_cidr                 = var.vpc_cidr
  availability_zones_count = var.availability_zones_count
  create_public_subnets    = var.create_public_subnets
  create_private_subnets   = var.create_private_subnets
  create_data_subnets      = var.create_data_subnets
  nat_gateway_ha           = var.nat_gateway_ha
}

locals {
  vpc_id          = var.create_vpc ? module.vpc.vpc_id : var.vpc_id
  public_subnets  = var.create_vpc ? module.vpc.public_subnet_ids : var.alb_subnets
  private_subnets = var.create_vpc ? module.vpc.private_subnet_ids : []
}

#=============================================================================================
# SECURITY GROUPS MODULE
#=============================================================================================
module "security_groups" {
  source = "./modules/security-groups"

  project_name              = var.project_name
  environment               = var.environment
  vpc_id                    = local.vpc_id
  ecs_services              = var.ecs_services
  create_alb                = var.alb_listener_arn == ""
  create_alb_security_group = var.create_alb_security_group
  alb_security_groups       = var.alb_security_groups

  depends_on = [module.vpc]
}

locals {
  alb_sg_id          = var.alb_listener_arn == "" && var.create_alb_security_group ? module.security_groups.alb_security_group_id : null
  ecs_service_sg_ids = module.security_groups.ecs_service_security_group_ids
}

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
# ECS CLUSTER MODULE (Condicional - só cria se não existir)
#=============================================================================================
module "ecs_cluster" {
  source = "./modules/ecs-cluster"
  count  = var.create_ecs_cluster ? 1 : 0

  cluster_name = "${var.environment}-${var.project_name}-cluster"

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

locals {
  cluster_id   = var.create_ecs_cluster ? module.ecs_cluster[0].cluster_id : var.ecs_cluster_id
  cluster_name = var.create_ecs_cluster ? module.ecs_cluster[0].cluster_name : var.ecs_cluster_name
}

#=============================================================================================
# ALB MODULE (Condicional - só cria se não existir)
#=============================================================================================
module "alb" {
  source = "./modules/alb"
  count  = var.alb_listener_arn == "" ? 1 : 0

  project_name    = var.project_name
  environment     = var.environment
  vpc_id          = local.vpc_id
  subnets         = local.public_subnets
  security_groups = module.security_groups.alb_security_groups
  certificate_arn = var.certificate_arn
  alb_internal    = var.alb_internal

  depends_on = [module.vpc, module.security_groups]
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
  service_name = each.key
  cluster_id   = local.cluster_id
  cluster_name = local.cluster_name

  # Definições da Task
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

  # Redes
  desired_count   = each.value.desired_count
  subnets         = length(each.value.subnets) > 0 ? each.value.subnets : local.private_subnets
  security_groups = each.value.create_security_group ? [local.ecs_service_sg_ids[each.key]] : each.value.security_groups

  # Load Balancer
  create_target_group = each.value.create_target_group
  health_check_path   = each.value.health_check_path
  vpc_id              = local.vpc_id
  alb_listener_arn    = local.alb_listener_arn
  alb_priority        = each.value.alb_priority
  host_header         = each.value.host_header

  # Tags
  application_tag = each.value.application_tag
  cost_center     = each.value.cost_center

  depends_on = [module.vpc, module.alb, module.iam_roles, module.ecs_cluster]
}