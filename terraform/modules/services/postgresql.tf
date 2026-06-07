


resource "random_password" "postgresql" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
  min_lower        = 2
  min_upper        = 2
  min_numeric      = 2
  min_special      = 2
}

resource "azurerm_key_vault_secret" "postgresql_password" {
  name         = "postgresql-${var.postgresql_name}-password"
  value        = random_password.postgresql.result
  key_vault_id = azurerm_key_vault.main.id
}

resource "azurerm_postgresql_flexible_server" "main" {
  name                          = var.postgresql_name
  location                      = data.terraform_remote_state.network.outputs.location
  resource_group_name           = data.terraform_remote_state.network.outputs.resource_group_name
  version                       = "16"
  delegated_subnet_id           = data.terraform_remote_state.network.outputs.database_subnet_id
  private_dns_zone_id           = azurerm_private_dns_zone.postgresql.id
  administrator_login           = var.postgresql_admin_login
  administrator_password        = random_password.postgresql.result
  zone                          = "1"
  public_network_access_enabled = false

  # high_availability {
  #   mode                      = "ZoneRedundant"
  #   standby_availability_zone = "2"
  # }

    storage_mb = 32768
    auto_grow_enabled = true
  

  sku_name = "B_Standard_B1ms"

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false

  # maintenance_window {
  #   day_of_week  = 0
  #   start_hour   = 2
  #   start_minute = 0
  # }
}

data "azurerm_key_vault_secret" "postgresql_password" {
  name         = "postgresql-${var.postgresql_name}-password"
  key_vault_id = azurerm_key_vault.main.id
  depends_on   = [azurerm_key_vault_secret.postgresql_password]
}

resource "azurerm_private_dns_zone" "postgresql" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = data.terraform_remote_state.network.outputs.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgresql" {
  name                  = "dns-link-postgresql"
  resource_group_name   = data.terraform_remote_state.network.outputs.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.postgresql.name
  virtual_network_id    = data.terraform_remote_state.network.outputs.spoke_vnet_id
  registration_enabled  = false
}