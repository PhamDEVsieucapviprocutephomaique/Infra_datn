
resource "azurerm_postgresql_flexible_server" "main" {
  name                          = var.postgresql_name
  location                      = data.terraform_remote_state.network.outputs.location
  resource_group_name           = data.terraform_remote_state.network.outputs.resource_group_name
  version                       = "17"
  delegated_subnet_id           = data.terraform_remote_state.network.outputs.database_subnet_id
  private_dns_zone_id           = azurerm_private_dns_zone.postgresql.id
  administrator_login           = var.postgresql_admin_login
  administrator_password        = var.postgresql_admin_password
  zone                          = "1"
  public_network_access_enabled = false

  high_availability {
    mode                      = "ZoneRedundant"
    standby_availability_zone = "2"
  }

  storage {
    size_gb           = 128
    auto_grow_enabled = true
  }

  sku_name = "GP_Standard_D4s_v3"

  backup_retention_days        = 30
  geo_redundant_backup_enabled = true

  maintenance_window {
    day_of_week  = 0
    start_hour   = 2
    start_minute = 0
  }
}

# Private DNS Zone cho PostgreSQL
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