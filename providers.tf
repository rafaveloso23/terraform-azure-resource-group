provider "azurerm" {
  features {}
  subscription_id = "cc323661-bdfb-4e37-8224-b9f41308d182"
  client_id       = "07c8c7c7-647f-4c2f-92f9-41326eef863a"
  #client_secret   = var.client_secret
  tenant_id       = "0eed3ea8-f35c-4862-b14a-9809318064c7"
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
      configuration_aliases = [ azurerm.teste, azurerm ]
    }
  }
}

provider "azurerm" {
  features {}
  alias = "teste"
}
#######
# terraform {
#   cloud {
#     organization = "veloso"
#     hostname     = "app.terraform.io" # Optional; defaults to app.terraform.io

#     workspaces {
#       project = "Default Project"
#       name    = "teste01"
#     }
#   }
# }