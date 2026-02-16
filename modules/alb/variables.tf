variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "security_groups" {
  type = list(string)
}

variable "certificate_arn" {
  type = string
}

variable "alb_internal" {
  type        = bool
  description = "Se true, ALB interno (apenas VPC). Se false, ALB público (internet-facing)"
  default     = false
}
