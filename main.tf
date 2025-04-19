module "resource-group" {
  source  = "app.terraform.io/veloso/resource-group/azure"
  version = "1.0.1"
  client_secret = var.client_secret
  resource_group_name = "rg-teste01"
  depends_on = [ azurerm_resource_group.name ]
}

module "storage" {
  source  = "app.terraform.io/veloso/storage/azure"
  version = "1.0.1"
  rg_location = "East US"
  rg_name     = module.resource-group.resource_group_name
  depends_on = [ module.resource-group ]
}

resource "azurerm_resource_group" "name" {
  name = "rg"
  location = "East US"
}