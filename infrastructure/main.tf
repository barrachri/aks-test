terraform {
  required_version = ">= 0.15"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.60.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "infrastructure"
    storage_account_name = "filesforplatform"
    container_name       = "terraformstates"
    key                  = "ml_platform.env.tfstate"
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.ml_cluster.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.ml_cluster.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.ml_cluster.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.ml_cluster.kube_config.0.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.ml_cluster.kube_config.0.host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.ml_cluster.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.ml_cluster.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.ml_cluster.kube_config.0.cluster_ca_certificate)
  }
}