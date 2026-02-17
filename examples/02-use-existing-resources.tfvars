#=============================================================================================
# EXEMPLO 2: USAR RECURSOS EXISTENTES
#=============================================================================================
# Este exemplo usa:
# - VPC existente com subnets já criadas
# - ECS Cluster existente
# - Application Load Balancer (ALB) existente
# - Security Groups existentes
# - Cria apenas os ECS Services
#=============================================================================================

#=============================================================================================
# GLOBAL VARIABLES
#=============================================================================================
# environment          = Ambiente de deploy (development, staging, production, qa)
# project_name         = Nome do projeto (usado em nomenclatura de recursos, máx 20 chars)
# aws_region           = Região AWS (us-east-1, us-east-2, sa-east-1)
#=============================================================================================
environment  = "staging"
project_name = "myapp"
aws_region   = "us-east-1"

#=============================================================================================
# VPC CONFIGURATION - USAR VPC EXISTENTE
#=============================================================================================
# vpc_id = ID da VPC existente no formato vpc-xxxxxxxx
#=============================================================================================
create_vpc = false
vpc_id     = "vpc-0123456789abcdef0"

# Variáveis abaixo são obrigatórias mas ignoradas quando create_vpc=false (pode deixar os valores padrão)
vpc_cidr                 = "10.0.0.0/16"
availability_zones_count = 2
create_public_subnets    = false
create_private_subnets   = false
create_data_subnets      = false
nat_gateway_ha           = false

#=============================================================================================
# ECS CLUSTER CONFIGURATION - USAR CLUSTER EXISTENTE
#=============================================================================================
# ecs_cluster_id   = ARN do cluster existente (ex: arn:aws:ecs:us-east-1:123456789012:cluster/my-cluster)
# ecs_cluster_name = Nome do cluster existente
#=============================================================================================
create_ecs_cluster = false
ecs_cluster_id     = "arn:aws:ecs:us-east-1:123456789012:cluster/my-existing-cluster"
ecs_cluster_name   = "my-existing-cluster"

#=============================================================================================
# ALB CONFIGURATION - USAR ALB EXISTENTE
#=============================================================================================
# alb_listener_arn    = ARN do listener HTTPS existente
# alb_security_groups = Security group IDs existentes do ALB
#=============================================================================================
alb_listener_arn          = "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener/app/my-alb/1234567890abcdef/1234567890abcdef"
create_alb_security_group = false
alb_security_groups       = ["sg-0123456789abcdef0"]

# Variáveis abaixo são obrigatórias mas ignoradas quando alb_listener_arn está preenchido
certificate_arn = ""
alb_subnets     = []
alb_internal    = false

#=============================================================================================
# ECS SERVICES CONFIGURATION
#=============================================================================================
# container_image       = URL completa da imagem Docker no ECR
# container_port        = Porta que o container expõe (1-65535)
# task_cpu              = vCPU da task: "256", "512", "1024", "2048", "4096"
# task_memory           = Memória em MB: "512", "1024", "2048", "4096", "8192"
# desired_count         = Número de tasks desejadas (mínimo 1)
# subnets               = Subnet IDs privadas onde as tasks serão executadas
# security_groups       = Security group IDs existentes para as tasks
# secrets_arn           = ARN do secret no Secrets Manager (vazio se não usar)
# create_target_group   = true: cria target group (APIs/web) | false: sem TG (workers/cron)
# health_check_path     = Caminho do health check (ex: /health, /api/v1/health)
# alb_priority          = Prioridade da regra no ALB (1-50000, deve ser único por listener)
# host_header           = Domínio para roteamento (ex: api.exemplo.com)
# application_tag       = Nome da aplicação (usado na tag Application)
# cost_center           = Centro de custo (usado na tag CostCenter)
# log_retention_in_days = Dias de retenção dos logs no CloudWatch (1, 3, 5, 7, 14, 30, etc)
#=============================================================================================
ecs_services = {
  "api" = {
    container_image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-api:latest"
    container_port  = 8080
    task_cpu        = "256"
    task_memory     = "512"
    desired_count   = 1

    subnets = [
      "subnet-0abcdef1234567890",
      "subnet-0abcdef1234567891"
    ]
    create_security_group = false
    security_groups       = ["sg-0abcdef1234567890"]

    secrets_arn = ""

    create_target_group = true
    health_check_path   = "/health"
    alb_priority        = 10
    host_header         = "api-staging.example.com"

    application_tag = "API Service"
    cost_center     = "Engineering"

    log_retention_in_days = 1
  }

  "worker" = {
    container_image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-worker:latest"
    container_port  = 3000
    task_cpu        = "256"
    task_memory     = "512"
    desired_count   = 1

    subnets = [
      "subnet-0abcdef1234567890",
      "subnet-0abcdef1234567891"
    ]
    create_security_group = false
    security_groups       = ["sg-0abcdef1234567891"]

    secrets_arn = ""

    create_target_group = false
    health_check_path   = ""
    alb_priority        = 0
    host_header         = ""

    application_tag = "Background Worker"
    cost_center     = "Engineering"

    log_retention_in_days = 1
  }
}
