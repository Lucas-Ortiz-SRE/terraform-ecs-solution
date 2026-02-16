# ------------------------------------------------------------------------------
# 1. Criação do Cluster
# ------------------------------------------------------------------------------
module "ecs_cluster" {
  source = "./modules/ecs-cluster"

  cluster_name = "${var.environment}-${var.project_name}-cluster"

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}