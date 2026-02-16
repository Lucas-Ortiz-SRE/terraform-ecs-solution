#=============================================================================================
# GLOBAL VARIABLES
#=============================================================================================
variable "environment" {
  type        = string
  description = "Ambiente de deploy (ex: dev, qa, prod)"
  validation {
    condition     = contains(["development", "stage", "production", "qa"], var.environment)
    error_message = "A variável environment aceita somente os valores: development, stage, production, qa"
  }
}

variable "project_name" {
  type        = string
  description = "Nome do projeto"
}

variable "aws_region" {
  type        = string
  description = "Região da AWS onde os recursos serão criados"

  validation {
    condition     = contains(["us-east-1", "us-east-2", "sa-east-1"], var.aws_region)
    error_message = "A variável aws_region aceita somente: us-east-1, us-east-2, sa-east-1"
  }
}

variable "vpc_id" {
  type        = string
  description = "ID da VPC onde os recursos de rede serão alocados"
}

#=============================================================================================
# ALB VARIABLES
#=============================================================================================
variable "alb_listener_arn" {
  type        = string
  description = "ARN do listener HTTPS existente. Se vazio, cria um novo ALB"
  default     = ""
}

variable "certificate_arn" {
  type        = string
  description = "ARN do certificado SSL/TLS para HTTPS (necessário se criar novo ALB)"
  default     = ""
}

variable "alb_subnets" {
  type        = list(string)
  description = "Subnets públicas para o ALB (necessário se criar novo)"
  default     = []
}

variable "alb_security_groups" {
  type        = list(string)
  description = "Security groups para o ALB (necessário se criar novo)"
  default     = []
}

variable "alb_internal" {
  type        = bool
  description = "Se true, ALB interno (apenas VPC). Se false, ALB público (internet-facing)"
  default     = false
}

#=============================================================================================
# ECS SERVICES VARIABLES
#=============================================================================================
variable "ecs_services" {
  description = "Mapa estrito contendo as configurações individuais de cada serviço ECS"
  type = map(object({
    container_image = string
    container_port  = number
    task_cpu        = string
    task_memory     = string
    desired_count   = number

    subnets         = list(string)
    security_groups = list(string)

    secrets_arn = string

    create_target_group = bool
    health_check_path   = string
    alb_priority        = number
    host_header         = string

    application_tag = string
    cost_center     = string

    log_retention_in_days = number
  }))
}