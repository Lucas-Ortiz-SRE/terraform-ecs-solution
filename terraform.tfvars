#=============================================================================================
# GLOBAL VARIABLES
#=============================================================================================
# environment = valores aceitos: development, stage, production, qa
# project_name = nome do projeto
# aws_region = valores aceitos: us-east-1, us-east-2, sa-east-1
# vpc_id = id da VPC que será utilizada
#=============================================================================================
environment  = "production"
project_name = "pagamentos"
aws_region   = "us-east-1"
vpc_id       = "vpc-0123456789abcdef0"

#=============================================================================================
# ALB CONFIGURATION
#=============================================================================================
# alb_listener_arn = ARN do listener HTTPS existente (deixe vazio para criar novo ALB)
# certificate_arn = ARN do certificado SSL/TLS (obrigatório se criar novo ALB)
# alb_subnets = lista de subnets públicas para o ALB
# alb_security_groups = lista de security groups para o ALB
# alb_internal = false para ALB público (internet), true para ALB interno (apenas VPC)
#=============================================================================================
# Cenário 1: Usar ALB existente (descomente e preencha)
# alb_listener_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener/app/my-alb/xxx/yyy"

# Cenário 2: Criar novo ALB (descomente e preencha)
alb_listener_arn    = ""
certificate_arn     = "arn:aws:acm:us-east-1:123456789012:certificate/xxx-xxx-xxx"
alb_subnets         = ["subnet-pub1", "subnet-pub2"]
alb_security_groups = ["sg-alb-xxx"]
alb_internal        = false

#=============================================================================================
# ECS SERVICES VARIABLES
#=============================================================================================
# container_image = URL da imagem Docker no ECR
# container_port = porta que o container expõe
# task_cpu = CPU da task (valores: 256, 512, 1024, 2048, 4096)
# task_memory = memória da task em MB (valores: 512, 1024, 2048, 4096, 8192)
# desired_count = número de tasks desejadas
# subnets = lista de subnets privadas para as tasks
# security_groups = lista de security groups para as tasks
# secrets_arn = ARN do secret no Secrets Manager (deixe vazio se não usar)
# create_target_group = true para APIs/web, false para workers
# health_check_path = caminho do health check (ex: /health, /api/health)
# alb_priority = prioridade da regra no ALB (único por listener)
# host_header = domínio para roteamento (ex: api.exemplo.com)
# application_tag = nome da aplicação para tag
# cost_center = centro de custo para tag
# log_retention_in_days = dias de retenção dos logs no CloudWatch
#=============================================================================================
ecs_services = {
  "api-pagamentos" = {
    container_image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/api-pagamentos:v1.2.0"
    container_port  = 3000
    task_cpu        = "512"
    task_memory     = "1024"
    desired_count   = 2

    subnets         = ["subnet-0a1b2c3d", "subnet-0e4f5g6h"]
    security_groups = ["sg-0123456789abcdef0"]

    secrets_arn = "arn:aws:secretsmanager:us-east-1:123456789012:secret:prod/api-pagamentos-xyz123"

    create_target_group = true
    health_check_path   = "/api/v1/health"
    alb_priority        = 100
    host_header         = "api-pagamentos.exemplo.com"

    application_tag = "Pagamentos API"
    cost_center     = "TI-001"

    log_retention_in_days = 7
  }

  "worker-processamento" = {
    container_image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/worker-proc:v2.0.1"
    container_port  = 8080
    task_cpu        = "256"
    task_memory     = "512"
    desired_count   = 1

    subnets         = ["subnet-0a1b2c3d", "subnet-0e4f5g6h"]
    security_groups = ["sg-0987654321fedcba0"]
    secrets_arn     = ""

    create_target_group = false
    health_check_path   = ""
    alb_priority        = 0
    host_header         = ""

    application_tag = "Worker Processamento"
    cost_center     = "TI-002"

    log_retention_in_days = 7
  }
}