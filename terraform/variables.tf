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

variable "domain" {
  description = "Доменное имя сертификата балансировщика"
  type        = string
  default     = "project77.test"
}

variable "lb_https_port" {
  description = "Порт хоста, на котором балансировщик принимает HTTPS"
  type        = number
  default     = 8443
}
