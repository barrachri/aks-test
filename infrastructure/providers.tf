terraform {
  required_version = ">= 0.15"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.60.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "=1.5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.3.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.1.2"
    }
  }
  backend "azurerm" {
    resource_group_name  = "infrastructure"
    storage_account_name = "filesforplatform"
    container_name       = "terraformstates"
    key                  = "ml_platform.env.tfstate"
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {
}

data "azurerm_kubernetes_cluster" "default" {
  depends_on          = [azurerm_kubernetes_cluster.ml_cluster]
  name                = local.cluster_name
  resource_group_name = local.resource_group_name_platform
}

provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.default.kube_config.0.host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.default.kube_config.0.host
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.cluster_ca_certificate)
  }
}