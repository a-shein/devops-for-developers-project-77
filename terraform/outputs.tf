output "app_urls" {
  description = "Прямые адреса веб-серверов"
  value       = [for i in range(var.app_count) : "http://localhost:${8081 + i}"]
}

output "lb_url" {
  description = "HTTPS-адрес балансировщика"
  value       = "https://localhost:${var.lb_https_port}"
}
