# Алерт Datadog: приложение на каждом сервере «живое» — агент выполняет HTTP-запрос
# к экземпляру приложения (http_check, см. ansible/playbook.yml), монитор срабатывает при сбоях.
resource "datadog_monitor" "app_alive" {
  count   = var.monitoring_enabled ? var.app_count : 0
  name    = "Redmine on ${docker_container.app[count.index].name} is down"
  type    = "service check"
  message = "Приложение не отвечает на HTTP на сервере ${docker_container.app[count.index].name}."

  query = "\"http.can_connect\".over(\"instance:${docker_container.app[count.index].name}\").by(\"*\").last(2).count_by_status()"

  monitor_thresholds {
    ok       = 1
    warning  = 1
    critical = 1
  }

  notify_no_data      = true
  no_data_timeframe   = 5
  require_full_window = false
}
