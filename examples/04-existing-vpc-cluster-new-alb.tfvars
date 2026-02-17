#=============================================================================================
# EXEMPLO 4: VPC E CLUSTER EXISTENTES + CRIAR ALB E SECURITY GROUPS NOVOS
#=============================================================================================
# Este exemplo usa:
# - VPC existente com subnets já criadas
# - ECS Cluster existente (compartilhado)
# E cria:
# - Novo Application Load Balancer (ALB) para este conjunto de aplicações
# - Novos Security Groups para ALB e ECS Services
# - ECS Services com tasks Fargate
#
# Cenário comum: Separar APIs públicas de APIs internas com ALBs diferentes no mesmo cluster
#=============================================================================================

#=============================================================================================
# GLOBAL VARIABLES
#=============================================================================================
# environment          = Ambiente de deploy (development, staging, production, qa)
# project_name         = Nome do projeto (usado em nomenclatura de recursos, máx 20 chars)
# aws_region           = Região AWS (us-east-1, us-east-2, sa-east-1)
#=============================================================================================
environment  = "production"
project_name = "internal-api"
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
# ecs_cluster_id   = ARN do cluster existente
# ecs_cluster_name = Nome do cluster existente
#=============================================================================================
create_ecs_cluster = false
ecs_cluster_id     = "arn:aws:ecs:us-east-1:123456789012:cluster/shared-production-cluster"
ecs_cluster_name   = "shared-production-cluster"

#=============================================================================================
# ALB CONFIGURATION - CRIAR NOVO ALB
#=============================================================================================
# alb_listener_arn          = Deixe VAZIO ("") para criar um novo ALB
# certificate_arn           = ARN do certificado SSL/TLS no ACM (obrigatório para HTTPS)
# alb_subnets               = Subnet IDs públicas existentes onde o ALB será criado
# create_alb_security_group = true: cria novo SG para o ALB | false: usa SG existente
# alb_security_groups       = Deixe VAZIO ([]) quando create_alb_security_group=true
# alb_internal              = false: ALB público (acesso pela internet) | true: ALB privado (apenas dentro da VPC)
#=============================================================================================
alb_listener_arn = ""  # Vazio = cria novo ALB
certificate_arn  = "arn:aws:acm:us-east-1:123456789012:certificate/your-certificate-id"
alb_subnets = [
  "subnet-pub1a2b3c4d5e6f7g8",
  "subnet-pub9h8i7j6k5l4m3n"
]
alb_internal = true  # true = ALB privado (internal)

# Security Group do ALB
create_alb_security_group = true  # Cria novo SG para o ALB
alb_security_groups       = []    # Vazio porque create_alb_security_group=true

#=============================================================================================
# ECS SERVICES CONFIGURATION
#=============================================================================================
# container_image       = URL completa da imagem Docker no ECR
# container_port        = Porta que o container expõe (1-65535)
# task_cpu              = vCPU da task: "256", "512", "1024", "2048", "4096"
# task_memory           = Memória em MB: "512", "1024", "2048", "4096", "8192"
# desired_count         = Número de tasks desejadas (mínimo 1)
# subnets               = Subnet IDs privadas existentes onde as tasks serão executadas
# create_security_group = true: cria novo SG para o service | false: usa SG existente
# security_groups       = Security group IDs existentes (obrigatório se create_security_group=false)
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
  "admin-api" = {
    container_image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/admin-api:latest"
    container_port  = 8080
    task_cpu        = "256"
    task_memory     = "512"
    desired_count   = 1

    subnets = [
      "subnet-priv1a2b3c4d5e6f",
      "subnet-priv7g8h9i0j1k2l"
    ]
    create_security_group = true
    security_groups       = []

    secrets_arn = ""

    create_target_group = true
    health_check_path   = "/health"
    alb_priority        = 10
    host_header         = "admin-internal.example.com"

    application_tag = "Admin API"
    cost_center     = "Operations"

    log_retention_in_days = 1
  }

  "reports-api" = {
    container_image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/reports-api:latest"
    container_port  = 3000
    task_cpu        = "256"
    task_memory     = "512"
    desired_count   = 1

    subnets = [
      "subnet-priv1a2b3c4d5e6f",
      "subnet-priv7g8h9i0j1k2l"
    ]
    create_security_group = true
    security_groups       = []

    secrets_arn = ""

    create_target_group = true
    health_check_path   = "/health"
    alb_priority        = 20
    host_header         = "reports-internal.example.com"

    application_tag = "Reports API"
    cost_center     = "Operations"

    log_retention_in_days = 1
  }
}
