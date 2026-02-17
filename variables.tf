#=============================================================================================
# GLOBAL VARIABLES
#=============================================================================================
variable "environment" {
  type        = string
  description = "Ambiente de deploy da infraestrutura"
  validation {
    condition     = contains(["development", "staging", "production", "qa"], var.environment)
    error_message = "Environment deve ser: development, staging, production ou qa."
  }
}

variable "project_name" {
  type        = string
  description = "Nome do projeto usado para nomenclatura de recursos"
  validation {
    condition     = length(var.project_name) > 0 && length(var.project_name) <= 20
    error_message = "Project name deve ter entre 1 e 20 caracteres."
  }
}

variable "aws_region" {
  type        = string
  description = "Região AWS onde os recursos serão provisionados"
  validation {
    condition     = contains(["us-east-1", "us-east-2", "sa-east-1"], var.aws_region)
    error_message = "AWS region deve ser: us-east-1, us-east-2 ou sa-east-1."
  }
}

variable "vpc_id" {
  type        = string
  description = "ID da VPC existente (obrigatório apenas se create_vpc = false)"
  default     = ""
  validation {
    condition     = var.vpc_id == "" || can(regex("^vpc-[a-f0-9]{8,17}$", var.vpc_id))
    error_message = "VPC ID deve estar no formato vpc-xxxxxxxx."
  }
}

#=============================================================================================
# ECS CLUSTER VARIABLES
#=============================================================================================
variable "create_ecs_cluster" {
  type        = bool
  description = "Define se um novo cluster ECS será criado (true) ou se usará cluster existente (false)"
  default     = true
}

variable "ecs_cluster_id" {
  type        = string
  description = "ID do cluster ECS existente (obrigatório apenas se create_ecs_cluster = false)"
  default     = ""
}

variable "ecs_cluster_name" {
  type        = string
  description = "Nome do cluster ECS existente (obrigatório apenas se create_ecs_cluster = false)"
  default     = ""
}

#=============================================================================================
# VPC VARIABLES
#=============================================================================================
variable "create_vpc" {
  type        = bool
  description = "Define se uma nova VPC será criada (true) ou se usará VPC existente (false)"
  default     = false
}

variable "vpc_cidr" {
  type        = string
  description = "Bloco CIDR da VPC (obrigatório se create_vpc = true)"
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR deve ser um bloco CIDR válido (ex: 10.0.0.0/16)."
  }
}

variable "availability_zones_count" {
  type        = number
  description = "Número de Availability Zones para distribuir os recursos (mínimo 1, máximo 3)"
  validation {
    condition     = var.availability_zones_count >= 1 && var.availability_zones_count <= 3
    error_message = "Availability zones count deve ser entre 1 e 3."
  }
}

variable "create_public_subnets" {
  type        = bool
  description = "Define se subnets públicas serão criadas (necessário para ALB internet-facing)"
}

variable "create_private_subnets" {
  type        = bool
  description = "Define se subnets privadas serão criadas (necessário para ECS tasks)"
}

variable "create_data_subnets" {
  type        = bool
  description = "Define se subnets data serão criadas (recomendado para RDS, ElastiCache, etc)"
}

variable "nat_gateway_ha" {
  type        = bool
  description = "Define se haverá 1 NAT Gateway por AZ (true = HA/caro) ou 1 total (false = econômico)"
}

#=============================================================================================
# ALB VARIABLES
#=============================================================================================
variable "alb_listener_arn" {
  type        = string
  description = "ARN do listener HTTPS existente (deixe vazio para criar novo ALB)"
  default     = ""
  validation {
    condition     = var.alb_listener_arn == "" || can(regex("^arn:aws:elasticloadbalancing:", var.alb_listener_arn))
    error_message = "ALB listener ARN deve ser um ARN válido do ELB ou vazio."
  }
}

variable "certificate_arn" {
  type        = string
  description = "ARN do certificado SSL/TLS no ACM (obrigatório se criar novo ALB)"
  default     = ""
  validation {
    condition     = var.certificate_arn == "" || can(regex("^arn:aws:acm:", var.certificate_arn))
    error_message = "Certificate ARN deve ser um ARN válido do ACM ou vazio."
  }
}

variable "alb_subnets" {
  type        = list(string)
  description = "Lista de subnet IDs públicas para o ALB (obrigatório se create_vpc = false e criar novo ALB)"
  default     = []
}

variable "create_alb_security_group" {
  type        = bool
  description = "Define se um novo security group será criado para o ALB (true) ou se usará existente (false)"
  default     = true
}

variable "alb_security_groups" {
  type        = list(string)
  description = "Lista de security group IDs existentes para o ALB (obrigatório se create_alb_security_group = false)"
  default     = []
}

variable "alb_internal" {
  type        = bool
  description = "Define se ALB é interno/privado (true) ou internet-facing/público (false)"
  default     = false
}

#=============================================================================================
# ECS SERVICES VARIABLES
#=============================================================================================
variable "ecs_services" {
  description = "Mapa de configurações dos serviços ECS (cada chave é um service único)"
  type = map(object({
    container_image = string # URL completa da imagem Docker no ECR
    container_port  = number # Porta que o container expõe (1-65535)
    task_cpu        = string # vCPU da task: "256", "512", "1024", "2048", "4096"
    task_memory     = string # Memória em MB: "512", "1024", "2048", "4096", "8192"
    desired_count   = number # Número de tasks desejadas (mínimo 1)

    subnets               = list(string) # Subnet IDs privadas (vazio se create_vpc=true)
    create_security_group = bool         # true para criar novo SG, false para usar existente
    security_groups       = list(string) # Security group IDs existentes (obrigatório se create_security_group=false)

    secrets_arn = string # ARN do secret no Secrets Manager (vazio se não usar)

    create_target_group = bool   # true para APIs/web, false para workers/cron
    health_check_path   = string # Caminho do health check (ex: /health)
    alb_priority        = number # Prioridade da regra no ALB (1-50000, único)
    host_header         = string # Domínio para roteamento (ex: api.exemplo.com)

    application_tag = string # Nome da aplicação para tag Application
    cost_center     = string # Centro de custo para tag CostCenter

    log_retention_in_days = number # Dias de retenção dos logs (1, 3, 5, 7, 14, 30, etc)
  }))
}