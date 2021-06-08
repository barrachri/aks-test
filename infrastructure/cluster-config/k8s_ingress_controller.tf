// https://kubernetes.github.io/ingress-nginx/

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
    value = var.lb_resource_group_name
  }

  set {
    name  = "controller.service.loadBalancerIP"
    value = var.lb_public_ip
  }

}