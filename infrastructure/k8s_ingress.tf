resource "kubernetes_ingress" "development-ingress" {
  metadata {
    name = "${var.environment}-ingress"
    annotations = {
      "kubernetes.io/ingress.class"              = "nginx"
      "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
    }
  }

  spec {

    rule {
      http {
        path {
          backend {
            service_name = "aspnetapp"
            service_port = 80
          }

          path = "/*"
        }

      }
    }

  }
}
