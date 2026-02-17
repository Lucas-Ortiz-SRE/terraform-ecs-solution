#=============================================================================================
# ECS CLUSTER
#=============================================================================================
# Cria o cluster ECS onde os services serão executados
resource "aws_ecs_cluster" "this" {
  name = var.cluster_name

  tags = var.tags
}

#=============================================================================================
# ECS CLUSTER CAPACITY PROVIDERS
#=============================================================================================
# Configura os capacity providers do cluster (FARGATE e FARGATE_SPOT)
# Define FARGATE como provider padrão com peso 100 e base 1
resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}