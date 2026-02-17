variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "ecs_services" {
  type = map(any)
}

variable "create_alb" {
  type = bool
}

variable "create_alb_security_group" {
  type = bool
}

variable "alb_security_groups" {
  type    = list(string)
  default = []
}
