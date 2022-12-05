data "azurerm_key_vault" "global" {
  provider            = azurerm.global
  name                = var.global_key_vault.name
  resource_group_name = var.global_key_vault.resource_group_name
}

data "azurerm_key_vault_certificate" "ssl" {
  provider     = azurerm.global
  name         = var.global_ssl_certificate_name
  key_vault_id = data.azurerm_key_vault.global.id

  depends_on = [
    azurerm_key_vault_access_policy.key_vault_administrator
  ]
}

data "azurerm_key_vault_secret" "ssl" {
  provider     = azurerm.global
  name         = reverse(split("/", data.azurerm_key_vault_certificate.ssl.versionless_secret_id)).0
  key_vault_id = data.azurerm_key_vault.global.id

  depends_on = [
    azurerm_key_vault_access_policy.key_vault_administrator
  ]
}

resource "azurerm_key_vault_access_policy" "key_vault_administrator" {
  provider                = azurerm.global
  certificate_permissions = ["Backup", "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers", "Import", "List", "ListIssuers", "ManageContacts", "ManageIssuers", "Purge", "Recover", "Restore", "SetIssuers", "Update"]
  secret_permissions      = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]
  key_permissions         = ["Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey", "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"]
  key_vault_id            = data.azurerm_key_vault.global.id
  object_id               = data.azurerm_client_config.main.object_id
  tenant_id               = data.azurerm_client_config.main.tenant_id
}

resource "azurerm_key_vault_access_policy" "identity" {
  provider           = azurerm.global
  secret_permissions = ["Get", "List"]
  key_vault_id       = data.azurerm_key_vault.global.id
  object_id          = azurerm_user_assigned_identity.main.principal_id
  tenant_id          = data.azurerm_client_config.main.tenant_id
}

data "azurerm_key_vault_certificate_data" "ssl" {
  name         = data.azurerm_key_vault_certificate.ssl.name
  key_vault_id = data.azurerm_key_vault_certificate.ssl.key_vault_id
}
