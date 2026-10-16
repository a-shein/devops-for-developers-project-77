# Локальный «DNS-хостинг»: CoreDNS отдаёт зону домена с A-записью на балансировщик.
# Реальный домен не регистрируется (платно), используется зарезервированная зона .test.
resource "docker_image" "dns" {
  name         = "coredns/coredns:1.11.3"
  keep_locally = true
}

resource "docker_container" "dns" {
  name    = "project77-dns"
  image   = docker_image.dns.image_id
  restart = "always"
  command = ["-conf", "/etc/coredns/Corefile"]

  ports {
    internal = 53
    external = var.dns_port
    protocol = "udp"
    ip       = "127.0.0.1"
  }

  ports {
    internal = 53
    external = var.dns_port
    protocol = "tcp"
    ip       = "127.0.0.1"
  }

  networks_advanced {
    name = docker_network.infra.name
  }

  upload {
    file    = "/etc/coredns/Corefile"
    content = <<-EOT
      ${var.domain}:53 {
          file /etc/coredns/${var.domain}.db
          log
      }
    EOT
  }

  upload {
    file = "/etc/coredns/${var.domain}.db"
    content = templatefile("${path.module}/zone.db.tftpl", {
      domain = var.domain
      lb_ip  = var.lb_ip
    })
  }
}
