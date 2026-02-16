#=============================================================================================
# GLOBAL VARIABLES
#=============================================================================================
variable "environment" {
  type        = string
  description = "Ambiente de deploy (ex: dev, qa, prod)"
  validation {
    condition = condition(["development", "stage", "production", "qa"],var.environment)
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
    condition = condition(["us-east-1", "us-east-2", "sa-east-1"], var.aws_region)
    error_message = "A variável aws_region aceita somente: us-east-1, us-east-2, sa-east-1"
  }

}

#=========================================================
# ECS VARIABLES
#=========================================================