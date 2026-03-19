terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "colima"
}

module "backend" {
  source         = "./modules/k8s-service"
  name           = "shopizer-backend"
  image          = var.backend_image
  container_port = 8080
  node_port      = 30090
  replicas       = 2
}

module "admin" {
  source         = "./modules/k8s-service"
  name           = "shopizer-admin"
  image          = var.admin_image
  container_port = 80
  node_port      = 30091
  replicas       = 2
  env_vars = {
    APP_BASE_URL = "http://${var.backend_host}:30090/api"
  }
}

module "shop" {
  source         = "./modules/k8s-service"
  name           = "shopizer-shop"
  image          = var.shop_image
  container_port = 80
  node_port      = 30001
  replicas       = 2
  env_vars = {
    APP_BASE_URL = "http://${var.backend_host}:30090"
  }
}
