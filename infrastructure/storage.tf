// Azure storage for machine learning users, accessible through k8s

locals {
  storage_name = "myk8sstorageaccount"
}

resource "azurerm_storage_account" "k8s_storage" {
  name                = local.storage_name
  resource_group_name = azurerm_resource_group.application.name

  location                 = azurerm_resource_group.application.location
  account_tier             = "Standard"
  account_replication_type = "LRS"


  tags = {
    environment = var.environment
  }
}

resource "azurerm_storage_container" "k8s_storage" {
  name                  = "data"
  storage_account_name  = azurerm_storage_account.k8s_storage.name
  container_access_type = "private"
}