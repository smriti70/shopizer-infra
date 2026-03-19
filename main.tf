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
    APP_BASE_URL = "http://shopizer.local/api"
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
    APP_BASE_URL = "http://shopizer.local"
  }
}

resource "kubernetes_ingress_v1" "shopizer" {
  metadata {
    name = "shopizer"
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
    }
  }

  spec {
    rule {
      host = "shopizer.local"

      http {
        path {
          path      = "/api"
          path_type = "Prefix"
          backend {
            service {
              name = "shopizer-backend"
              port { number = 8080 }
            }
          }
        }

        path {
          path      = "/admin"
          path_type = "Prefix"
          backend {
            service {
              name = "shopizer-admin"
              port { number = 80 }
            }
          }
        }

        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "shopizer-shop"
              port { number = 80 }
            }
          }
        }
      }
    }
  }
}
