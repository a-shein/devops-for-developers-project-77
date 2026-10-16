resource "docker_network" "infra" {
  name = "project77"
}

resource "docker_image" "postgres" {
  name         = "postgres:16"
  keep_locally = true
}

resource "docker_image" "app" {
  name         = "redmine:5"
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
  count   = var.app_count
  name    = "project77-app${count.index + 1}"
  image   = docker_image.app.image_id
  restart = "always"

  env = [
    "REDMINE_DB_POSTGRES=db",
    "REDMINE_DB_DATABASE=redmine",
    "REDMINE_DB_USERNAME=redmine",
    "REDMINE_DB_PASSWORD=${var.db_password}",
  ]

  ports {
    internal = 3000
    external = 8081 + count.index
  }

  networks_advanced {
    name = docker_network.infra.name
  }

  depends_on = [docker_container.db]
}
