resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}


resource "azurerm_virtual_network" "hub" {
  name                = var.hub_vnet_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.0.0.0/16"]
}


resource "azurerm_virtual_network" "spoke" {
  name                = var.spoke_vnet_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_virtual_network_peering" "hub_spoke" {
  name                      = var.hub_spoke
  resource_group_name       = azurerm_resource_group.main.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.spoke.id
  allow_forwarded_traffic      = true

}
resource "azurerm_virtual_network_peering" "spoke_hub" {
  name                      = var.spoke_hub
  resource_group_name       = azurerm_resource_group.main.name
  virtual_network_name      = azurerm_virtual_network.spoke.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
  allow_forwarded_traffic      = true

}

//subnet hub


resource "azurerm_subnet" "firewall_subnet" {
  name                 = var.firewall_subnet_name
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.1.0/24"]
}
resource "azurerm_subnet" "bastion_subnet" {
  name                 = var.bastion_subnet_name
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.2.0/24"]
}
resource "azurerm_subnet" "appgw" {
  name                 = var.appgw_subnet_name
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.3.0/24"]
}






// subnets spoke
resource "azurerm_subnet" "system_pool_subnet" {
  name                 = var.system_pool_subnet_name
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = ["10.1.1.0/24"]
  service_endpoints    = ["Microsoft.KeyVault", "Microsoft.ContainerRegistry"]
}
resource "azurerm_subnet" "app_pool_subnet" {
  name                 = var.app_pool_subnet_name
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = ["10.1.2.0/24"]
  service_endpoints    = ["Microsoft.KeyVault", "Microsoft.ContainerRegistry"]
}
resource "azurerm_subnet" "cron_job_pool_subnet" {
  name                 = var.cron_job_pool_subnet_name
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = ["10.1.3.0/24"]
  service_endpoints    = ["Microsoft.KeyVault", "Microsoft.ContainerRegistry"]
}
resource "azurerm_subnet" "kafka_subnet" {
  name                 = var.kafka_subnet_name
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = ["10.1.4.0/24"]
}
resource "azurerm_subnet" "database" {
  name                 = var.database_subnet_name
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = ["10.1.5.0/24"]

  delegation {
    name = "postgresql-delegation"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }
  }
}