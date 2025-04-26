resource "azurerm_resource_group" "rg" {
  name     = "rg-veloso"
  location = var.location
  tags     = var.tags
}####