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
  depends_on          = [module.cluster]
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

module "cluster" {
  source              = "./cluster"
  cluster_name        = local.cluster_name
  environment         = var.environment
  location            = azurerm_resource_group.platform.location
  resource_group_name = azurerm_resource_group.platform.name
  resource_group_id   = azurerm_resource_group.platform.id
  vnet_subnet_id      = azurerm_subnet.k8s_subnet.id
}

locals {
  storage_secret = {
    principal_id     = azuread_service_principal.pod_runner.object_id
    principal_secret = azuread_service_principal_password.pod_runner.value
  }
}

module "cluster-config" {
  depends_on             = [module.cluster]
  source                 = "./cluster-config"
  environment            = var.environment
  lb_public_ip           = azurerm_public_ip.lb_public_ip.ip_address
  lb_resource_group_name = local.resource_group_name_platform
  storage_secret         = local.storage_secret
}
