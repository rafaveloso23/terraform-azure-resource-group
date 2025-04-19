module "resource-group" {
  source  = "app.terraform.io/veloso/resource-group/azure"
  version = "1.0.1"
  client_secret = var.client_secret
  resource_group_name = "rg-teste"
  depends_on = [ azurerm_resource_group.name ]
}

module "storage" {
  source  = "app.terraform.io/veloso/storage/azure"
  version = "1.0.0"
  rg_location = module.resource-group.resource_group_location
  rg_name     = module.resource-group.resource_group_name
}

resource "azurerm_resource_group" "name" {
  name = "rg"
  location = "East US"
}