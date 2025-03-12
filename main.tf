resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# resource "null_resource" "show_plan" {
#   provisioner "local-exec" {
#     command = "terraform show -json tfplan.out > plan_metadata.json"
#   }
# }


# data "local_file" "plan_metadata" {
#   depends_on = [null_resource.show_plan]
#   filename = "${path.module}/plan_metadata.json"
# }

# locals {
#   plan_metadata = jsondecode(data.local_file.plan_metadata.content)
#   timestamp     = local.plan_metadata.timestamp
#   applyable     = local.plan_metadata.applyable
#   complete      = local.plan_metadata.complete
#   errored       = local.plan_metadata.errored
# }

# output "timestamp" {
#   value = local.timestamp
# }

# output "applyable" {
#   value = local.applyable
# }

# output "complete" {
#   value = local.complete
# }

# output "errored" {
#   value = local.errored
# }
