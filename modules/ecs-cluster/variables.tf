#=============================================================================================
# GLOBAL VARIABLES
#=============================================================================================
variable "cluster_name" {
  type        = string
  description = "Nome do cluster ECS"
}

variable "tags" {
  type        = map(string)
  description = "Tags padrão para os recursos do cluster"
  default     = {}
}

#=========================================================
# ECS CLUSTER VARIABLES
#=========================================================
