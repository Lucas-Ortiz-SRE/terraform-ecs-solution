variable "project_name" {
  type        = string
  description = "Nome do projeto"
}

variable "environment" {
  type        = string
  description = "Ambiente de deploy"
}

variable "service_name" {
  type = string
}
variable "cluster_id" {
  type = string
}
variable "cluster_name" {
  type = string
} # Necessário para compor o nome do Log Group

# --- Configurações da Task e Contentor ---
variable "container_image" {
  type        = string
  description = "A imagem Docker a ser utilizada (ex: ECR URL)"
}

variable "task_cpu" {
  type = string
}

variable "task_memory" {
  type = string
}

variable "container_port" {
  type = number
}

variable "secrets_arn" {
  type        = string
  description = "ARN do secret no Secrets Manager"
  default     = ""
}

# --- Observabilidade ---
variable "log_retention_in_days" {
  type = number
}

# --- IAM Roles (Serão passadas via módulo externo) ---
variable "execution_role_arn" {
  type = string
}
variable "task_role_arn" {
  type = string
}

# --- Configurações de Rede e Escalonamento ---
variable "desired_count" {
  type = number
}
variable "subnets" {
  type = list(string)
}
variable "security_groups" {
  type = list(string)
}

# --- Load Balancer (Opcional) ---
variable "create_target_group" {
  type        = bool
  description = "Define se o serviço precisa de um Target Group (true para APIs, false para Workers)"
}

variable "vpc_id" {
  type        = string
  description = "ID da VPC (Obrigatório se create_target_group for true)"
  default     = ""
}

variable "health_check_path" {
  type        = string
  description = "Caminho do health check da aplicação"
  default     = "/"
}

variable "application_tag" {
  type        = string
  description = "Nome da aplicação para tag"
}

variable "cost_center" {
  type        = string
  description = "Centro de custo para tag"
}

variable "alb_listener_arn" {
  type        = string
  description = "ARN do listener HTTPS do ALB"
  default     = ""
}

variable "alb_priority" {
  type        = number
  description = "Prioridade da regra no listener"
  default     = null
}

variable "host_header" {
  type        = string
  description = "Domínio para roteamento no ALB"
  default     = ""
}