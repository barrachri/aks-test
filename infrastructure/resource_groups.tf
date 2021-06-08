resource "azurerm_resource_group" "platform" {
  name     = local.resource_group_name_platform
  location = var.location
}

resource "azurerm_resource_group" "application" {
  name     = "ml-application"
  location = var.location
}
