terraform {
  cloud {
    organization = "veloso"
    hostname     = "app.terraform.io"

    workspaces {
      project = "modules"
      name    = "terraform-azure-resource-group"
    }
  }
}
