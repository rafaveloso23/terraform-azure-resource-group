variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "client_secret" {
  type = string
}

variable "stg_name" {
  type = string
}
