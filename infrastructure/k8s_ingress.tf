# resource "kubernetes_ingress" "development-ingress" {
#   metadata {
#     name = "${var.environment}-ingress"
#     annotations = {
#       "kubernetes.io/ingress.class"              = "nginx"
#       "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
#     }
#   }

#   spec {

#     rule {
#       http {
#         path {
#           backend {
#             service_name = "aspnetapp"
#             service_port = 80
#           }

#           path = "/*"
#         }

#       }
#     }

#   }
# }

locals {
  nginx_ingress = "nginx-ingress"
}

resource "kubernetes_namespace" "nginx-ingress" {
  metadata {
    name = local.nginx_ingress
  }
}

resource "helm_release" "nginx-ingress" {
  name       = local.nginx_ingress
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = local.nginx_ingress

  set {
    name  = "controller.replicaCount"
    value = 2
  }
  
  set {
    name  = "controller.nodeSelector.beta\\.kubernetes\\.io/os"
    value = "linux"
  }

  set {
    name  = "controller.admissionWebhooks.patch.nodeSelector.beta\\.kubernetes\\.io/os"
    value = "linux"
  }

  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Local"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-resource-group"
    value = azurerm_resource_group.platform.name
  }
  
  set {
    name  = "controller.service.loadBalancerIP"
    value = azurerm_public_ip.lb-public-ip.ip_address
  }

}