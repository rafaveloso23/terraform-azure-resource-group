# terraform {
#   backend "azurerm" {
#     resource_group_name  = "testerg"
#     storage_account_name = "stgtfstatetvsf"
#     container_name       = "cntf"
#     key                  = "terraform.tfstate"
#   }
# }

# terraform {
#   cloud {
#     organization = "veloso"
#     hostname     = "app.terraform.io"

#     workspaces {
#       project = "modules"
#       name    = "terraform-azure-resource-group"
#     }
#   }
# }
