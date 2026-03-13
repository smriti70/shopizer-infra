terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {
  host = "unix:///Users/${var.username}/.colima/default/docker.sock"
}

variable "username" {
  description = "macOS username for Colima socket path"
  default     = "smritisingh"
}

variable "backend_host" {
  description = "Host IP accessible from other containers"
  default     = "192.168.29.34"
}

# ── Network ──────────────────────────────────────────────────────────────────

resource "docker_network" "shopizer" {
  name = "shopizer-network"
}

# ── Images ───────────────────────────────────────────────────────────────────

resource "docker_image" "backend" {
  name         = "smriti70/shopizer-backend:latest"
  keep_locally = false
}

resource "docker_image" "admin" {
  name         = "smriti70/shopizer-admin:latest"
  keep_locally = false
}

resource "docker_image" "shop" {
  name         = "smriti70/shopizer-shop:latest"
  keep_locally = false
}

# ── Backend ───────────────────────────────────────────────────────────────────

resource "docker_container" "backend" {
  name  = "shopizer-backend"
  image = docker_image.backend.image_id

  ports {
    internal = 8080
    external = 8090
  }

  networks_advanced {
    name = docker_network.shopizer.name
  }

  restart = "unless-stopped"
}

# ── Admin ─────────────────────────────────────────────────────────────────────

resource "docker_container" "admin" {
  name  = "shopizer-admin"
  image = docker_image.admin.image_id

  ports {
    internal = 80
    external = 8091
  }

  env = [
    "APP_BASE_URL=http://${var.backend_host}:8090/api"
  ]

  networks_advanced {
    name = docker_network.shopizer.name
  }

  restart = "unless-stopped"
}

# ── Shop ──────────────────────────────────────────────────────────────────────

resource "docker_container" "shop" {
  name  = "shopizer-shop"
  image = docker_image.shop.image_id

  ports {
    internal = 80
    external = 3001
  }

  env = [
    "APP_BASE_URL=http://${var.backend_host}:8090"
  ]

  networks_advanced {
    name = docker_network.shopizer.name
  }

  restart = "unless-stopped"
}
