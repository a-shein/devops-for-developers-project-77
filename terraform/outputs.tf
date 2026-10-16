output "app_urls" {
  description = "Прямые адреса веб-серверов"
  value       = [for i in range(var.app_count) : "http://localhost:${8081 + i}"]
}

output "lb_url" {
  description = "HTTPS-адрес балансировщика"
  value       = "https://localhost:${var.lb_https_port}"
}

# Инвентори для Ansible (make inventory записывает его в ansible/inventory.ini)
output "ansible_inventory" {
  value = templatefile("${path.module}/inventory.ini.tftpl", {
    servers = [for i, c in docker_container.app : { name = c.name, api_port = 2375 + i }]
    db_host = docker_container.db.network_data[0].ip_address
  })
}
