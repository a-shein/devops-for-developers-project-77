resource "docker_network" "infra" {
  name = "project77"
}

resource "docker_image" "postgres" {
  name         = "postgres:16"
  keep_locally = true
}

# «Виртуальные машины» — контейнеры docker:dind: у каждой свой Docker-демон,
# в который Ansible затем деплоит приложение (по API на 127.0.0.1:2375+N).
resource "docker_image" "server" {
  name         = "docker:27-dind"
  keep_locally = true
}

resource "docker_container" "db" {
  name    = "project77-db"
  image   = docker_image.postgres.image_id
  restart = "always"

  env = [
    "POSTGRES_DB=redmine",
    "POSTGRES_USER=redmine",
    "POSTGRES_PASSWORD=${var.db_password}",
  ]

  networks_advanced {
    name    = docker_network.infra.name
    aliases = ["db"]
  }
}

resource "docker_container" "app" {
  count      = var.app_count
  name       = "project77-app${count.index + 1}"
  image      = docker_image.server.image_id
  restart    = "always"
  privileged = true

  env = ["DOCKER_TLS_CERTDIR="]

  # Docker API сервера — только с localhost, для Ansible
  ports {
    internal = 2375
    external = 2375 + count.index
    ip       = "127.0.0.1"
  }

  # Порт приложения, которое Ansible запустит внутри сервера
  ports {
    internal = 3000
    external = 8081 + count.index
  }

  networks_advanced {
    name = docker_network.infra.name
  }
}
