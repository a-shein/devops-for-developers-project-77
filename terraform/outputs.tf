output "app_urls" {
  value = [for i in range(var.app_count) : "http://localhost:${8081 + i}"]
}
