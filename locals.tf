locals {
  project                  = var.project == null ? random_string.project.result : var.project
  environment              = terraform.workspace == "default" ? var.environment : terraform.workspace
  resource_suffix          = "${local.project}-${local.environment}-${var.region}"
  global_resource_suffix   = "${local.project}-${local.environment}"
  load_balancer_ip_address = cidrhost(azurerm_subnet.cluster.address_prefixes.0, pow(2, 32 - tonumber(split("/", var.address_space.aks).1)) - 2)
  availability_zones       = ["1", "2", "3"]
  api_host_name            = "api-${local.project}"
}
