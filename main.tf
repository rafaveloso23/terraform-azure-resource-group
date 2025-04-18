module "resource-group" {
  source  = "app.terraform.io/veloso/resource-group/azure"
  version = "1.0.1"
  client_secret = var.client_secret
  resource_group_name = "rg-teste"
  # insert required variables here
  depends_on = [ azurerm_resource_group.name ]
}
resource "azurerm_resource_group" "name" {
  name = "rg"
  location = "East US"
}