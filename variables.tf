variable "location" {
  type        = string
  description = "Región de Azure definida para el sandbox"
  default     = "South Central US"
}

variable "resource_group_name" {
  type        = string
  description = "Nombre del Resource Group pre-asignado en el sandbox"
  default     = "1-e11996eb-playground-sandbox"
}

variable "sql_admin_username" {
  type        = string
  description = "Usuario administrador para el servidor SQL"
  default     = "sqladmin-devops"
}

variable "sql_admin_password" {
  type        = string
  description = "Contraseña de administrador para el servidor SQL"
  sensitive   = true
}