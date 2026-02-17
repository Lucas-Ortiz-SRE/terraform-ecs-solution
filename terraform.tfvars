#=============================================================================================
# GLOBAL VARIABLES
#=============================================================================================
# environment          = Ambiente de deploy (development, staging, production, qa)
# project_name         = Nome do projeto (usado em nomenclatura de recursos, máx 20 chars)
# aws_region           = Região AWS (us-east-1, us-east-2, sa-east-1)
#=============================================================================================
environment  = "qa"
project_name = "ortiz"
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
# Cenário 1: Criar nova VPC
create_vpc               = true
vpc_cidr                 = "10.0.0.0/16"
availability_zones_count = 2
create_public_subnets    = true
create_private_subnets   = true
create_data_subnets      = true
nat_gateway_ha           = false

# Cenário 2: Usar VPC existente (descomente as linhas abaixo)
# create_vpc = false
# vpc_id     = "vpc-0123456789abcdef0"
# IMPORTANTE: Quando usar VPC existente, preencha manualmente as subnets em:
#             - alb_subnets (subnets públicas)
#             - ecs_services[].subnets (subnets privadas)

#=============================================================================================
# ECS CLUSTER CONFIGURATION
#=============================================================================================
# create_ecs_cluster = true: cria novo cluster | false: usa cluster existente
# ecs_cluster_id     = ID do cluster existente (obrigatório se create_ecs_cluster=false)
# ecs_cluster_name   = Nome do cluster existente (obrigatório se create_ecs_cluster=false)
#=============================================================================================
# Cenário 1: Criar novo cluster
create_ecs_cluster = true

# Cenário 2: Usar cluster existente (descomente as linhas abaixo)
# create_ecs_cluster = false
# ecs_cluster_id     = "arn:aws:ecs:us-east-1:123456789012:cluster/my-cluster"
# ecs_cluster_name   = "my-cluster"

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
# Cenário 1: Usar ALB existente (descomente a linha abaixo)
# alb_listener_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener/app/my-alb/xxx/yyy"

# Cenário 2: Criar novo ALB
alb_listener_arn = "" # vazio = cria novo ALB
certificate_arn  = "arn:aws:acm:us-east-1:762593866570:certificate/6f183dc2-01f8-4e3d-aff0-8bb0b0239250"
alb_subnets      = [] # Vazio se create_vpc=true. Preencha se create_vpc=false: ["subnet-pub1", "subnet-pub2"]
alb_internal     = false

# Security Group do ALB
create_alb_security_group = true # true: cria novo SG | false: usa SG existente
alb_security_groups       = []   # Preencha apenas se create_alb_security_group=false: ["sg-alb-xxx"]

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
  "api-pagamentos" = {
    container_image = "762593866570.dkr.ecr.us-east-1.amazonaws.com/teste-ortiz"
    container_port  = 3000
    task_cpu        = "256"
    task_memory     = "512"
    desired_count   = 1

    subnets               = []   # Vazio se create_vpc=true. Preencha se create_vpc=false: ["subnet-priv1", "subnet-priv2"]
    create_security_group = true # true: cria novo SG | false: usa SG existente
    security_groups       = []   # Preencha apenas se create_security_group=false: ["sg-xxx"]

    secrets_arn = "arn:aws:secretsmanager:us-east-1:762593866570:secret:eduardo-validacao-terraform-n8n-ChaJHl"

    create_target_group = true
    health_check_path   = "/api/v1/health"
    alb_priority        = 2
    host_header         = "api-pagamentos.exemplo.com"

    application_tag = "Pagamentos API"
    cost_center     = "TI-001"

    log_retention_in_days = 1
  }

  "worker-processamento" = {
    container_image = "762593866570.dkr.ecr.us-east-1.amazonaws.com/teste-ortiz"
    container_port  = 8080
    task_cpu        = "256"
    task_memory     = "512"
    desired_count   = 1

    subnets               = []   # Vazio se create_vpc=true
    create_security_group = true # Usando SG existente
    security_groups       = []   # SG existente
    secrets_arn           = "arn:aws:secretsmanager:us-east-1:762593866570:secret:eduardo-validacao-terraform-n8n-ChaJHl"

    create_target_group = true
    health_check_path   = "/health"
    alb_priority        = 3
    host_header         = "pagamentos.exemplo.com"

    application_tag = "Worker Processamento"
    cost_center     = "TI-002"

    log_retention_in_days = 1
  }
}