resource "azurerm_log_analytics_workspace" "k8s_logs" {
  name                = "${var.environment}-k8s-logs"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
}

resource "azurerm_kubernetes_cluster" "ml_cluster" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "ml-cluster"

  default_node_pool {
    name           = "default"
    node_count     = 1
    vm_size        = var.node_pool_vm
    vnet_subnet_id = var.vnet_subnet_id
    node_labels = {
      "environment" = var.environment
    }
    tags = {
      environment = var.environment
    }
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }

  addon_profile {
    aci_connector_linux {
      enabled = false
    }

    azure_policy {
      enabled = false
    }

    http_application_routing {
      enabled = false
    }

    kube_dashboard {
      enabled = false
    }

    ingress_application_gateway {
      enabled = false
    }

    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.k8s_logs.id
    }
  }

}

// Give access to the AKS Cluster to use the Public IP
resource "azurerm_role_assignment" "aks_cluster_network" {
  scope                = var.resource_group_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.ml_cluster.identity[0].principal_id
}
