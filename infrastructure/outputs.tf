output "aks_cluster_name" {
  value = local.cluster_name
}

output "aks_cluster_group_name" {
  value = azurerm_resource_group.platform.name
}

output "aks_lb_public_ip" {
  value = azurerm_public_ip.lb_public_ip.ip_address
}
