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

variable "lb_ip" {
  description = "IP балансировщика, на который указывает A-запись домена"
  type        = string
  default     = "127.0.0.1"
}

variable "dns_port" {
  description = "Порт хоста локального DNS-сервера"
  type        = number
  default     = 5300
}
