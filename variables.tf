variable "resource_group_name" {
  type    = string
  default = "rg-name-region"
}

variable "location" {
  type    = string
  default = "East US"
}

variable "client_secret" {
  type    = string
}


variable "tags" {
  type = map(string)
  default = {
    environment = "dev"
    costcenter  = "it"
  }
}
###
# variable "rg_data" {
#   type = string
# }
# variable "client_secret" {
#   type = string
# }