#=============================================================================================
# GLOBAL VARIABLES
#=============================================================================================
variable "environment" {
  type        = string
  description = "Ambiente de deploy (ex: dev, qa, prod)"
  validation {
    condition     = condition(["development", "stage", "production", "qa"], var.environment)
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
    condition     = condition(["us-east-1", "us-east-2", "sa-east-1"], var.aws_region)
    error_message = "A variável aws_region aceita somente: us-east-1, us-east-2, sa-east-1"
  }

}

#=============================================================================================
# ECS SERVICES VARIABLES
#=============================================================================================
variable "ecs_services" {
  description = "Mapa estrito contendo as configurações individuais de cada serviço ECS"
  type = map(object({
    container_name  = string
    container_image = string
    
    # Recursos e Escalonamento (Agora 100% Obrigatórios)
    container_port  = number
    task_cpu        = string
    task_memory     = string
    desired_count   = number
    
    # Redes e Segurança
    subnets         = list(string)
    security_groups = list(string)
    
    # Secrets Manager
    secrets = list(object({
      name      = string
      valueFrom = string # O ARN do AWS Secrets Manager
    }))

    # Load Balancer (Passar "" se for um serviço interno)
    target_group_arn = string
  }))
}