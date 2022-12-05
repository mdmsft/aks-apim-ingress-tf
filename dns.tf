data "azurerm_dns_zone" "global" {
  provider            = azurerm.global
  name                = var.global_dns_zone.name
  resource_group_name = var.global_dns_zone.resource_group_name
}

resource "azurerm_dns_cname_record" "api" {
  provider            = azurerm.global
  name                = local.api_host_name
  zone_name           = data.azurerm_dns_zone.global.name
  resource_group_name = data.azurerm_dns_zone.global.resource_group_name
  ttl                 = 3600
  record              = "${azurerm_api_management.main.name}.azure-api.net"
}
