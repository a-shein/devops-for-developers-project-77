# Балансировщик нагрузки: nginx принимает HTTPS и раздаёт запросы на app-серверы.
# Самоподписанный сертификат генерирует Terraform (локальная замена облачному ALB + сертификату).
resource "tls_private_key" "lb" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "lb" {
  private_key_pem       = tls_private_key.lb.private_key_pem
  validity_period_hours = 8760
  allowed_uses          = ["key_encipherment", "digital_signature", "server_auth"]

  subject {
    common_name = var.domain
  }

  dns_names = [var.domain, "localhost"]
}

resource "docker_image" "nginx" {
  name         = "nginx:1.27"
  keep_locally = true
}

resource "docker_container" "lb" {
  name    = "project77-lb"
  image   = docker_image.nginx.image_id
  restart = "always"

  ports {
    internal = 443
    external = var.lb_https_port
  }

  networks_advanced {
    name = docker_network.infra.name
  }

  upload {
    file    = "/etc/nginx/ssl/tls.crt"
    content = tls_self_signed_cert.lb.cert_pem
  }

  upload {
    file    = "/etc/nginx/ssl/tls.key"
    content = tls_private_key.lb.private_key_pem
  }

  upload {
    file = "/etc/nginx/conf.d/default.conf"
    content = templatefile("${path.module}/nginx.conf.tftpl", {
      backends = [for c in docker_container.app : "${c.name}:3000"]
    })
  }
}
