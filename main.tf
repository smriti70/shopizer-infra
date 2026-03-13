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

resource "docker_network" "shopizer" {
  name = "shopizer-network"
}

module "backend" {
  source        = "./modules/container"
  name          = "shopizer-backend"
  image         = var.backend_image
  internal_port = 8080
  external_port = 8090
  network_name  = docker_network.shopizer.name
}

module "admin" {
  source        = "./modules/container"
  name          = "shopizer-admin"
  image         = var.admin_image
  internal_port = 80
  external_port = 8091
  network_name  = docker_network.shopizer.name
  env_vars      = ["APP_BASE_URL=http://${var.backend_host}:8090/api"]
}

module "shop" {
  source        = "./modules/container"
  name          = "shopizer-shop"
  image         = var.shop_image
  internal_port = 80
  external_port = 3001
  network_name  = docker_network.shopizer.name
  env_vars      = ["APP_BASE_URL=http://${var.backend_host}:8090"]
}
