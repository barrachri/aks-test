resource "azurerm_resource_group" "platform" {
  name     = "platform"
  location = var.location
}

resource "azurerm_resource_group" "application" {
  name     = "ml-application"
  location = var.location
}
