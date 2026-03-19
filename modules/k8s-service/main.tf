resource "kubernetes_deployment" "this" {
  metadata {
    name = var.name
    labels = { app = var.name }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = { app = var.name }
    }

    template {
      metadata {
        labels = { app = var.name }
      }

      spec {
        container {
          name  = var.name
          image = var.image

          port {
            container_port = var.container_port
          }

          dynamic "env" {
            for_each = var.env_vars
            content {
              name  = env.key
              value = env.value
            }
          }

          readiness_probe {
            http_get {
              path = "/"
              port = var.container_port
            }
            initial_delay_seconds = 10
            period_seconds        = 10
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "this" {
  metadata {
    name = var.name
  }

  spec {
    selector = { app = var.name }
    type     = "NodePort"

    port {
      port        = var.container_port
      target_port = var.container_port
      node_port   = var.node_port
    }
  }
}
