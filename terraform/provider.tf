terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
    datadog = {
      source  = "DataDog/datadog"
      version = "~> 3.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

# Локальный Docker вместо облака: серверы — контейнеры на этой машине.
provider "docker" {
  host = "unix:///var/run/docker.sock"
}

# Ключи Datadog приходят из secrets.auto.tfvars (Ansible Vault).
provider "datadog" {
  api_key  = var.dd_api_key
  app_key  = var.dd_app_key
  api_url  = var.dd_api_url
  validate = var.monitoring_enabled
}
