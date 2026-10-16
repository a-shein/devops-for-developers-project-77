variable "db_password" {
  description = "Пароль PostgreSQL (из Ansible Vault через secrets.auto.tfvars)"
  type        = string
  sensitive   = true
}

variable "app_count" {
  description = "Количество серверов приложения"
  type        = number
  default     = 2
}
