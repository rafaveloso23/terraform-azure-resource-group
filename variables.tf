variable "resource_group_name" {
  type    = string
  default = "rg-tdsfs"
}

variable "location" {
  type    = string
  default = "East US"
}

variable "tags" {
  type = map(string)
  default = {
    environment = "dev"
    costcenter  = "it"
  }
}

variable "client_secret" {
  type = string
}