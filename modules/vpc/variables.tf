variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "create_vpc" {
  type        = bool
  description = "Se true, cria nova VPC. Se false, usa VPC existente"
  default     = true
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR da VPC"
  default     = "10.0.0.0/16"
}

variable "availability_zones_count" {
  type        = number
  description = "Número de AZs (1-3)"
  default     = 2
}

variable "create_public_subnets" {
  type        = bool
  description = "Se true, cria subnets públicas"
  default     = true
}

variable "create_private_subnets" {
  type        = bool
  description = "Se true, cria subnets privadas"
  default     = true
}

variable "create_data_subnets" {
  type        = bool
  description = "Se true, cria subnets data (para RDS, etc)"
  default     = false
}

variable "nat_gateway_ha" {
  type        = bool
  description = "Se true, 1 NAT por AZ (HA). Se false, 1 NAT total (mais barato)"
  default     = false
}

variable "enable_dns_hostnames" {
  type        = bool
  description = "Habilita DNS hostnames na VPC"
  default     = true
}

variable "enable_dns_support" {
  type        = bool
  description = "Habilita DNS support na VPC"
  default     = true
}
