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
  type    = string
}

variable "task_memory" {
  type    = string
}

variable "container_port" {
  type    = number
}

variable "secrets" {
  type = string
  description = "Variavel para o secrets manager"
}

# --- Observabilidade ---
variable "log_retention_in_days" {
  type    = number
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
  type    = number
}
variable "subnets" {
  type = list(string)
}
variable "security_groups" {
  type = list(string)
}

# --- Load Balancer (Opcional) ---
variable "target_group_arn" {
  type    = string
  default = null
}
variable "container_name" {
  type        = string
  description = "Nome do contentor (crucial para o mapeamento do Load Balancer)"
}