variable "location" {
  type    = string
  default = "East US"
}

variable "client_secret" {
  type = string
}

variable "tags" {
  type = map(string)
}
