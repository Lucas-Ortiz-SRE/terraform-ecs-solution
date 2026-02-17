#=============================================================================================
# EXEMPLO 1: CRIAR TODOS OS RECURSOS DO ZERO
#=============================================================================================
# Este exemplo cria:
# - Nova VPC com subnets públicas, privadas e data
# - Novo ECS Cluster
# - Novo Application Load Balancer (ALB)
# - Novos Security Groups para ALB e ECS Services
# - ECS Services com tasks Fargate
#=============================================================================================

#=============================================================================================
# GLOBAL VARIABLES
#=============================================================================================
# environment          = Ambiente de deploy (development, staging, production, qa)
# project_name         = Nome do projeto (usado em nomenclatura de recursos, máx 20 chars)
# aws_region           = Região AWS (us-east-1, us-east-2, sa-east-1)
#=============================================================================================
environment  = "production"
project_name = "myapp"
aws_region   = "us-east-1"

#=============================================================================================
# VPC CONFIGURATION
#=============================================================================================
# create_vpc               = true: cria nova VPC | false: usa VPC existente (vpc_id obrigatório)
# vpc_id                   = ID da VPC existente no formato vpc-xxxxxxxx (apenas se create_vpc=false)
# vpc_cidr                 = Bloco CIDR da VPC (ex: 10.0.0.0/16) (apenas se create_vpc=true)
# availability_zones_count = Número de AZs para distribuir recursos (1-3)
# create_public_subnets    = true: cria subnets públicas (necessário para ALB internet-facing)
# create_private_subnets   = true: cria subnets privadas (necessário para ECS tasks)
# create_data_subnets      = true: cria subnets data (recomendado para RDS, ElastiCache)
# nat_gateway_ha           = false: 1 NAT total (econômico) | true: 1 NAT por AZ (alta disponibilidade)
#=============================================================================================
create_vpc               = true
vpc_cidr                 = "10.0.0.0/16"
availability_zones_count = 2
create_public_subnets    = true
create_private_subnets   = true
create_data_subnets      = true
nat_gateway_ha           = false

#=============================================================================================
# ECS CLUSTER CONFIGURATION
#=============================================================================================
# create_ecs_cluster = true: cria novo cluster | false: usa cluster existente
# ecs_cluster_id     = ID do cluster existente (obrigatório se create_ecs_cluster=false)
# ecs_cluster_name   = Nome do cluster existente (obrigatório se create_ecs_cluster=false)
#=============================================================================================
create_ecs_cluster = true

#=============================================================================================
# ALB CONFIGURATION
#=============================================================================================
# alb_listener_arn          = ARN do listener HTTPS existente (vazio = cria novo ALB)
# certificate_arn           = ARN do certificado SSL/TLS no ACM (obrigatório se criar novo ALB)
# alb_subnets               = Subnet IDs públicas (vazio se create_vpc=true, preencha se false)
# create_alb_security_group = true: cria novo SG para ALB | false: usa SG existente
# alb_security_groups       = Security group IDs existentes (obrigatório se create_alb_security_group=false)
# alb_internal              = false: ALB público (internet) | true: ALB interno (apenas VPC)
#=============================================================================================
alb_listener_arn = ""
certificate_arn  = "arn:aws:acm:us-east-1:123456789012:certificate/your-certificate-id"
alb_subnets      = []
alb_internal     = false

# Security Group do ALB
create_alb_security_group = true
alb_security_groups       = []

#=============================================================================================
# ECS SERVICES CONFIGURATION
#=============================================================================================
# container_image           = URL completa da imagem Docker no ECR
# container_port            = Porta que o container expõe (1-65535)
# task_cpu                  = vCPU da task: "256", "512", "1024", "2048", "4096"
# task_memory               = Memória em MB: "512", "1024", "2048", "4096", "8192"
# desired_count             = Número de tasks desejadas (mínimo 1)
# subnets                   = Subnet IDs privadas (vazio se create_vpc=true, preencha se false)
# create_security_group     = true: cria novo SG para o service | false: usa SG existente
# security_groups           = Security group IDs existentes (obrigatório se create_security_group=false)
# secrets_arn               = ARN do secret no Secrets Manager (vazio se não usar)
# create_target_group       = true: cria target group (APIs/web) | false: sem TG (workers/cron)
# health_check_path         = Caminho do health check (ex: /health, /api/v1/health)
# alb_priority              = Prioridade da regra no ALB (1-50000, deve ser único por listener)
# host_header               = Domínio para roteamento (ex: api.exemplo.com)
# application_tag           = Nome da aplicação (usado na tag Application)
# cost_center               = Centro de custo (usado na tag CostCenter)
# log_retention_in_days     = Dias de retenção dos logs no CloudWatch (1, 3, 5, 7, 14, 30, etc)
#=============================================================================================
ecs_services = {
  "api" = {
    container_image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-api:latest"
    container_port  = 8080
    task_cpu        = "512"
    task_memory     = "1024"
    desired_count   = 2

    subnets               = []
    create_security_group = true
    security_groups       = []

    secrets_arn = "arn:aws:secretsmanager:us-east-1:123456789012:secret:my-api-secrets-xxxxx"

    create_target_group = true
    health_check_path   = "/health"
    alb_priority        = 10
    host_header         = "api.example.com"

    application_tag = "API Service"
    cost_center     = "Engineering"

    log_retention_in_days = 7
  }

  "worker" = {
    container_image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-worker:latest"
    container_port  = 3000
    task_cpu        = "256"
    task_memory     = "512"
    desired_count   = 1

    subnets               = []
    create_security_group = true
    security_groups       = []

    secrets_arn = ""

    create_target_group = false
    health_check_path   = ""
    alb_priority        = 0
    host_header         = ""

    application_tag = "Background Worker"
    cost_center     = "Engineering"

    log_retention_in_days = 3
  }
}
