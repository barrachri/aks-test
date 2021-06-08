
resource "azurerm_virtual_network" "platform" {
  name                = "${var.environment}-k8s-platform-vnet"
  address_space       = ["10.128.0.0/16"]
  location            = azurerm_resource_group.platform.location
  resource_group_name = azurerm_resource_group.platform.name
}

resource "azurerm_subnet" "k8s_subnet" {
  name                 = "${var.environment}-k8s-subnet"
  resource_group_name  = azurerm_resource_group.platform.name
  virtual_network_name = azurerm_virtual_network.platform.name
  address_prefixes     = ["10.128.1.0/24"]
}

resource "azurerm_public_ip" "lb-public-ip" {
  name                = "aks-lb-public-ip"
  resource_group_name = azurerm_resource_group.platform.name
  location            = azurerm_resource_group.platform.location
  allocation_method   = "Static"
  sku                 = "Standard"
}
