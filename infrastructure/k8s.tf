resource "azurerm_log_analytics_workspace" "k8s_logs" {
  name                = "${var.environment}-k8s-logs"
  resource_group_name = azurerm_resource_group.platform.name
  location            = azurerm_resource_group.platform.location
  sku                 = "PerGB2018"
}

resource "azurerm_kubernetes_cluster" "ml_cluster" {
  name                = "${var.environment}-ml-cluster"
  location            = azurerm_resource_group.platform.location
  resource_group_name = azurerm_resource_group.platform.name
  dns_prefix          = "exampleaks1"

  default_node_pool {
    name           = "default"
    node_count     = 1
    vm_size        = var.node_pool_vm
    vnet_subnet_id = azurerm_subnet.k8s_subnet.id
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
  scope                = azurerm_resource_group.platform.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.ml_cluster.identity[0].principal_id
}

output "aks-cluster-name" {
  value = azurerm_kubernetes_cluster.ml_cluster.name
}

output "aks-cluster-group-name" {
  value = azurerm_kubernetes_cluster.ml_cluster.resource_group_name
}

output "service-principal-id" {
  value = azurerm_kubernetes_cluster.ml_cluster.identity[0].principal_id
}
