resource "random_pet" "api_publisher" {
  length    = 2
  separator = " "
}

resource "azurerm_public_ip" "api" {
  name                = "pip-${local.resource_suffix}-api"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
  sku                 = "Standard"
  public_ip_prefix_id = azurerm_public_ip_prefix.ingress.id
  zones               = local.availability_zones
  domain_name_label   = "${local.project}-api"
}

resource "azurerm_api_management" "main" {
  name                 = "apim-${local.resource_suffix}"
  resource_group_name  = azurerm_resource_group.main.name
  location             = azurerm_resource_group.main.location
  publisher_name       = title(random_pet.api_publisher.id)
  publisher_email      = "${lower(replace(random_pet.api_publisher.id, " ", "."))}@contoso.com"
  sku_name             = "Premium_${tostring(var.api_capacity * length(local.availability_zones))}"
  zones                = local.availability_zones
  public_ip_address_id = azurerm_public_ip.api.id
  virtual_network_type = "External"

  virtual_network_configuration {
    subnet_id = azurerm_subnet.api.id
  }

  protocols {
    enable_http2 = true
  }

  dynamic "additional_location" {
    for_each = var.api_additional_locations

    content {
      location = additional_location.key
      capacity = additional_location.value.capacity * length(additional_location.value.zones)
      zones    = additional_location.value.zones

      virtual_network_configuration {
        subnet_id = azurerm_subnet.api.id
      }
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.main.id]
  }
}

resource "azurerm_api_management_custom_domain" "main" {
  api_management_id = azurerm_api_management.main.id

  gateway {
    host_name                       = "${local.api_host_name}.${var.global_dns_zone.name}"
    key_vault_id                    = data.azurerm_key_vault_secret.ssl.versionless_id
    ssl_keyvault_identity_client_id = azurerm_user_assigned_identity.main.client_id
    default_ssl_binding             = true
  }
}

resource "azurerm_api_management_api" "main" {
  name                  = "hello-world"
  api_management_name   = azurerm_api_management.main.name
  resource_group_name   = azurerm_resource_group.main.name
  revision              = "1"
  api_type              = "http"
  display_name          = "Hello World"
  protocols             = ["http", "https"]
  description           = "Hello World API"
  subscription_required = false
  service_url           = "http://${local.load_balancer_ip_address}"

  import {
    content_format = "openapi+json"
    content_value  = file("${path.module}/api/openapi.json")
  }
}

resource "azurerm_api_management_api_policy" "main" {
  api_name            = azurerm_api_management_api.main.name
  api_management_name = azurerm_api_management.main.name
  resource_group_name = azurerm_resource_group.main.name
  xml_content         = file("${path.module}/api/policy.xml")
}
