# data "azurerm_resource_group" "rg" {
#   name = "rg-dnce${var.environment_suffix}"
# }

data "azurerm_resource_group" "rg" {
  name = "rg-${var.project_name}${var.environment_suffix}"
}

data "azurerm_key_vault" "kv" {
  name = "kb-dnce"
  resource_group_name = data.azurerm_resource_group.rg.name
}

########## postgres

data "azurerm_key_vault_secret" "postgres-login" {
  name = "postgres-login"
  key_vault_id = data.azurerm_key_vault.kv.id
}

data "azurerm_key_vault_secret" "postgres-password" {
  name = "postgres-password"
  key_vault_id = data.azurerm_key_vault.kv.id
}

########## token

data "azurerm_key_vault_secret" "refresh-token-secret" {
  name = "refresh-token-secret"
  key_vault_id = data.azurerm_key_vault.kv.id
}

data "azurerm_key_vault_secret" "access-token-secret" {
  name = "access-token-secret"
  key_vault_id = data.azurerm_key_vault.kv.id
}

########### pgadmin

data "azurerm_key_vault_secret" "pgadmin-email" {
  name = "pgadmin-email"
  key_vault_id = data.azurerm_key_vault.kv.id
}

data "azurerm_key_vault_secret" "pgadmin-password" {
  name = "pgadmin-password"
  key_vault_id = data.azurerm_key_vault.kv.id
}