terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

# Локальный Docker вместо облака: серверы — контейнеры на этой машине.
provider "docker" {
  host = "unix:///var/run/docker.sock"
}
