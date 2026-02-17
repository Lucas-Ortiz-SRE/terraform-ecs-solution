#=============================================================================================
# TERRAFORM CONFIGURATION
#=============================================================================================
# required_version = Versão mínima do Terraform necessária (>= 1.5.0)
# required_providers:
#   - aws: Provider da AWS versão ~> 5.0 (aceita 5.x, mas não 6.x)
# backend "s3":
#   - bucket: Nome do bucket S3 para armazenar o state file
#   - key: Caminho do arquivo state dentro do bucket (organizado por ambiente)
#   - region: Região AWS onde o bucket S3 está localizado
#   - use_lockfile: Habilita lock nativo do S3
#=============================================================================================
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

#   backend "s3" {
#     bucket = "ortiz-terraform-infrastructure-state"
#     key    = "infra/production/terraform.state"
#     region = "us-east-1"
#     use_lockfile = true
#   }
# }