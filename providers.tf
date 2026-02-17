#=============================================================================================
# AWS PROVIDER CONFIGURATION
#=============================================================================================
# region       = Região AWS onde os recursos serão provisionados (definida em variables.tf)
# default_tags = Tags aplicadas automaticamente em todos os recursos criados
#              - Environment: Ambiente de deploy (usa var.environment)
#              - Project: Nome do projeto (usa var.project_name)
#              - ManagedBy: Indica que a infraestrutura é gerenciada pelo Terraform
#=============================================================================================
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  }
}