resource "azurerm resource_group" "state" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "state" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.state.name
  location                 = azurerm_resource_group.state.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


resource "azurerm_storage_container" "example" {
  name                  = var.storage_container
  storage_account_id    = azurerm_storage_account.state.id
  container_access_type = "private"
}
