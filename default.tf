resource "azurerm_resource_group" "rg_app" {
  name     = "example-resources-appgw"
  location = "eastus"
}

resource "azurerm_virtual_network" "vnet_app" {
  name                = "example-network"
  resource_group_name = azurerm_resource_group.rg_app.name
  location            = azurerm_resource_group.rg_app.location
  address_space       = ["10.254.0.0/16"]
}

resource "azurerm_subnet" "snet_app" {
  name                 = "example"
  resource_group_name  = azurerm_resource_group.rg_app.name
  virtual_network_name = azurerm_virtual_network.vnet_app.name
  address_prefixes     = ["10.254.0.0/24"]
}

resource "azurerm_public_ip" "pip_appgw" {
  name                = "example-pip"
  resource_group_name = azurerm_resource_group.rg_app.name
  location            = azurerm_resource_group.rg_app.location
  allocation_method   = "Static"
  sku = "Standard"
}

resource "azurerm_user_assigned_identity" "identity" {
  name                = "example-identity"
  resource_group_name = azurerm_resource_group.rg_app.name
  location            = azurerm_resource_group.rg_app.location
}
